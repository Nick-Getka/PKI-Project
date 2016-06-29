#!/bin/bash
#Setup and install of the 389-directory server on a new RHEL server
#Variables
INF=/tmp/ks-$$.inf
hostname 389-Dir.localdomain
HOSTNAME==$(hostname)
TYPE="LDAP_Dir_Server"

#installing necessary packages
function package_install(){
 subscription-manager register --username=$1 --password=$2
 subscription-manager attach
 yum install java-1.7.0-openjdk -y
 yum install java-1.7.0-openjdk-devel -y
 rpm -Uvh http://download.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-7.noarch.rpm
 yum install foo 
 yum groupinstall Xfce -y
 yum install 389-ds-base openldap-clients -y
 yum install 389-ds-* -y
 yum install 389-* -y
 yum upgrade -y
}

#Setting and Resolving the hostname
function resolve_hostname(){ 
 IP="$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)"
 echo "$IP $HOSTNAME $TYPE">> /etc/hosts
}

#Allowing the 389-server ports
function open_ladp_ports(){
 firewall-cmd --zone=dmz --add-port=389/tcp --permanent
 firewall-cmd --zone=dmz --add-port=636/tcp --permanent
 firewall-cmd --zone=dmz --add-port=9830/tcp --permanent
 systemctl reload firewalld.service
}

#Creating user for server
function create_users(){
 useradd dirsrv
} 

#Setting up the Directory server with the default options
function create_inf(){
 cat > $INF <<EOF
[General] 
FullMachineName= $HOSTNAME
SuiteSpotUserID= dirsrv
SuiteSpotGroup= dirsrv 
AdminDomain= localdomain
ConfigDirectoryAdminID= admin 
ConfigDirectoryAdminPwd= practice1234
ConfigDirectoryLdapURL= ldap://$HOSTNAME:389/o=NetscapeRoot 

[slapd] 
SlapdConfigForMC= Yes 
UseExistingMC= 0 
ServerPort= 389 
ServerIdentifier= dir 
Suffix= dc=example,dc=com  
RootDN= cn=Directory Manager 
RootDNPwd= practice1234
ds_bename=exampleDB 
AddSampleEntries= No

[admin] 
Port= 9830
ServerIpAddress= $IP
ServerAdminID= admin 
ServerAdminPwd= practice1234
EOF
}

#Pre-setup functions
package_install
resolve_hostname
open_ladp_ports
create_users
create_inf

#Run Setup
setup-ds-admin.pl -s -f $INF

#Start and Enable service
systemctl start dirsrv.target
systemctl enable dirsrv.target

#Clean-up
rm -v $INF






