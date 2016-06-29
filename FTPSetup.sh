#Create FTP server using virt-manager
#Giving server FTP functions from techmint
#http://www.tecmint.com/rhcsa-series-install-and-secure-apache-web-server-and-ftp-in-rhel/
subscription-manager register --username=$1 --password=$2
subscription-manager attach
yum update -y && yum install httpd vsftpd -y
systemctl start httpd
systemctl enable httpd
systemctl start vsftpd
systemctl enable vsftpd
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-service=ftp --permanent
firewall-cmd --reload
vi /etc/vsftpd/vsftpd.conf
#vsftpd.conf techmint recommended settings
#anonymous_enable=NO
#local_enable=YES
#write_enable=YES
#local_umask=022
#dirmessage_enable=YES
#xferlog_enable=YES
#connect_from_port_20=YES
#xferlog_std_format=YES
#chroot_local_user=YES
#allow_writeable_chroot=YES
#listen=NO
#listen_ipv6=YES
#pam_service_name=vsftpd
#userlist_enable=YES
#tcp_wrappers=YES

setsebool -P ftp_home_dir on


#then send it the following files
#pass this script the FTP server's IP
#RHCertSys-9.0-RHEL-7-CertificateSystem-x86_64-dvd.iso
#rhel-server-7.2-x86_64-dvd.iso
#kickstart file
