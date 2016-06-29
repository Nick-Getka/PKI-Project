#!/bin/bash
#Apache Web Server Setup on RHEL 7
subscription-manager register --username=$1 --password=$2
subscription-manager attach
yum install httpd -y
yum install httpd-devel -y
yum install httpd-manual -y
yum install mod_ssl -y 
yum install autoconf -y
yum install automake -y
yum install libtool -y
yum upgrade -y

firewall-cmd --zone=dmz --add-port=80/tcp --permanent




