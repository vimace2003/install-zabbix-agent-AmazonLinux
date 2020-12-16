#!/bin/bash

# Set some needed variables
AMZLVERSION=$(rpm -E %{rhel})
ZABBIXHOST=""

# Get hostname of Zabbix-Server
if [ -z "$ZABBIXHOST" ]; then
        echo -n "==> Please input the hostname of your Zabbix Monitoring Server... [zabbix.example.org]: "
        read -r ZABBIXHOST
fi

# Get Amazon Linux version
if [[ $AMZLVERSION == *"6"* ]]; then
        wget -q http://repo.zabbix.com/zabbix/5.2/rhel/6/x86_64/zabbix-release-5.2-1.el6.noarch.rpm -O /tmp/zabbix.rpm
elif [[ $AMZLVERSION == *"7"* ]]; then
        wget -q http://repo.zabbix.com/zabbix/5.2/rhel/7/x86_64/zabbix-release-5.2-1.el7.noarch.rpm -O /tmp/zabbix.rpm
elif [[ $AMZLVERSION == *"8"* ]]; then
        wget -q http://repo.zabbix.com/zabbix/5.2/rhel/8/x86_64/zabbix-release-5.2-1.el8.noarch.rpm -O /tmp/zabbix.rpm
fi

# Install Zabbix-Repository, then update sources and install Zabbix-Agent and OpenSSL
    sudo rpm -Uvh /tmp/zabbix.rpm
    yum update
    sudo yum install zabbix-agent2 -y

# Generate Zabbix-Agent-Configuration
cat <<EOT >/etc/zabbix/zabbix_agent2.conf
PidFile=/var/run/zabbix/zabbix_agent2.pid
LogFile=/var/log/zabbix/zabbix_agent2.log
LogFileSize=0
Server=$ZABBIXHOST
ServerActive=$ZABBIXHOST
Hostname=$(hostname -f)
Include=/etc/zabbix/zabbix_agent2.d/*.conf
AllowKey=system.run[*]
HostMetadataItem=system.uname
EOT
# Restart Zabbix-Agent
service zabbix-agent2 restart >/dev/null 2>&1