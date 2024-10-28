#!/bin/bash

sudo yum install -y \
  amazon-ssm-agent \
  iptables-services

sudo systemctl enable amazon-ssm-agent
sudo systemctl start  amazon-ssm-agent
sudo systemctl enable iptables
sudo systemctl start  iptables

primary_network_interface=$(sudo /usr/bin/netstat -i | egrep -v 'Kernel|Iface|lo' | awk '{print $1}')
sudo /sbin/iptables -t nat -A POSTROUTING -o ${primary_network_interface} -j MASQUERADE
sudo /sbin/iptables -F FORWARD
sudo service iptables save

sudo cp /tmp/custom-ip-forwarding.conf /etc/sysctl.d/custom-ip-forwarding.conf
sudo rm /tmp/custom-ip-forwarding.conf
