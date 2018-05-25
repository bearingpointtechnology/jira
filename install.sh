#!/usr/bin/env bash
set -e

# prerequisites:
# wget
# tar

TMP_DIR="/tmp"

JAVA_NAME="jdk1.8.0_171"
JAVA_DOWNLOAD_URL="http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jdk-8u171-linux-x64.tar.gz"
JAVA_INSTALL_DIR="/usr/java"


JIRA_DOWNLOAD_LINK=https://product-downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-7.9.0.tar.gz
JIRA_INSTALL_DIR="/opt/atlassian/jira"
JIRA_NAME="atlassian-jira-software-7.9.0-standalone"

JIRA_HOME="/home/jira/jira"

# Install JAVA
wget -c --header "Cookie: oraclelicense=accept-securebackup-cookie" "${JAVA_DOWNLOAD_URL}" -O "${TMP_DIR}/java.tar.gz"
tar -xvf "${TMP_DIR}/java.tar.gz" -C "$TMP_DIR/"

mkdir -p "$JAVA_INSTALL_DIR"
mv "$TMP_DIR/$JAVA_NAME" "$JAVA_INSTALL_DIR/"
ln -s "$JAVA_INSTALL_DIR/$JAVA_NAME" "$JAVA_INSTALL_DIR/current"

## Prepare ENV
JAVA_HOME="$JAVA_INSTALL_DIR/current"
echo "export JAVA_HOME=$JAVA_HOME" >> /etc/environment
echo "export JRE_HOME=$JAVA_HOME/jre" >> /etc/environment
echo "export PATH=$PATH:$JAVA_HOME/bin" >> /etc/environment
ln -s "$JAVA_HOME/bin/java" "/usr/bin/java"


# Install JIRA
useradd jira
mkdir -p "$JIRA_INSTALL_DIR"
wget -c "${JIRA_DOWNLOAD_LINK}" -O "${TMP_DIR}/jira.tar.gz"
tar -xvf "${TMP_DIR}/jira.tar.gz" -C "$TMP_DIR/"
mv "$TMP_DIR/$JIRA_NAME" "$JIRA_INSTALL_DIR/"
ln -s "$JIRA_INSTALL_DIR/$JIRA_NAME" "$JIRA_INSTALL_DIR/current"

echo "export JIRA_HOME=$JIRA_HOME" >> /etc/environment
echo "source /etc/environment" >> /home/jira/.bashrc
mkdir -p "$JIRA_HOME"

chown -R jira:jira "$JIRA_INSTALL_DIR"
chown -R jira:jira "$JIRA_HOME"

wget https://raw.githubusercontent.com/bparsons/atlassian-systemd/master/jira.service -O /etc/systemd/system/jira.service
sed -i -- "s#/opt/atlassian/jira#$JIRA_INSTALL_DIR/current#g" /etc/systemd/system/jira.service

systemctl daemon-reload
systemctl enable jira.service

rm -f "$TMP_DIR/jira.tar.gz" "$TMP_DIR/java.tar.gz"