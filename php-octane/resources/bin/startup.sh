#!/usr/bin/env bash
#Add trusted CAs
source /etc/container/init_cacerts.sh

#Prepare SSH
ssh-keygen -A

#prepare SSH run dir
if [ ! -d "/var/run/sshd" ]; then
    mkdir -p /var/run/sshd
fi

#SSHD startup
sudo /usr/sbin/sshd
