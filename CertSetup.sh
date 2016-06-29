#!/bin/bash
CACONF=/tmp/ca-conf-$$.txt
KRACONF=/tmp/kra-conf-$$.txt
OCSPCONF=/tmp/ocsp-conf-$$.txt
TKSCONF=/tmp/tks-conf-$$.txt
TPSCONF=/tmp/tps-conf-$$.txt

hostname Cert.localdomain
LHOSTNAME=$(hostname)
LTYPE="Cert_Server"
LDAPIP=$1
LDAPHOST="389-Dir.localdomain"
LDAPTYPE="LDAP_Dir_Server"


#installing necessary packages
function package_install(){
 subscription-manager register --username=$2 --password=$3
 subscription-manager attach
 yum install java-1.7.0-openjdk -y
 yum install java-1.7.0-openjdk-devel -y
 yum install redhat-pki -y
 yum install pki-* -y
}

#Creating user for server
function create_users(){
 useradd Certadmin
} 

#Allowing the 389-server ports
function open_ladp_ports(){
 firewall-cmd --zone=dmz --add-port=389/tcp --permanent
 firewall-cmd --zone=dmz --add-port=636/tcp --permanent
 firewall-cmd --zone=dmz --add-port=9830/tcp --permanent
 systemctl reload firewalld.service
}

#Resolving the local and the LDAP IP addresses
function resolve_hosts(){
 IP="$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)"
 echo "$IP $HOSTNAME $TYPE">> /etc/hosts
 echo "$LDAPIP $LDAPHOST $LDAPTYPE">>/etc/hosts
}

function spawn_CA(){
 cat > $CACONF <<EOF
pki_admin_password=practice1234
pki_client_pkcs12_password=practice1234
pki_ds_password=practice1234
EOF

 pkispawn -s CA -f $CACONF
}

function spawn_KRA(){
 cat > $KRACONF <<EOF
pki_admin_password=practice1234
pki_client_database_password=practice1234
pki_client_pkcs12_password=practice1234
pki_ds_password=practice1234
pki_security_domain_password=practice1234
EOF

 pkispawn -s KRA -f $KRACONF
}

function spawn_OCSP(){
 cat > $OCSPCONF <<EOF
pki_admin_password=practice1234
pki_client_database_password=practice1234
pki_client_pkcs12_password=practice1234
pki_ds_password=practice1234
pki_security_domain_password=practice1234
EOF

 pkispawn -s OCSP -f $OCSPCONF
}

function spawn_TKS(){
 cat > $TKSCONF <<EOF
pki_admin_password=practice1234
pki_client_database_password=practice1234
pki_client_pkcs12_password=practice1234
pki_ds_password=practice1234
pki_security_domain_password=practice1234
EOF

 pkispawn -s TKS -f $TKSCONF
}

function spawn_TPS(){
 cat > $TPSCONF <<EOF
[DEFAULT]
pki_admin_password=practice1234
pki_client_database_password=practice1234
pki_client_pkcs12_password=practice1234
pki_ds_password=practice1234
pki_security_domain_password=practice1234
[TPS]
pki_authdb_basedn=dc=example,dc=com
EOF

 pkispawn -s TPS -f $TPSCONF
}

#Clean-up
function clear_files(){
 rm -v CACONF
 rm -v KRACONF
 rm -v OCSPCONF
 rm -v TKSCONF
 rm -v TPSCONF
}

package_install
create_users
open_ladp_ports
resolve_hosts
spawn_CA
spawn_KRA
spawn_OCSP
spawn_TKS
spawn_TPS
clear_files




