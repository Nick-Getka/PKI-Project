#!/bin/bash
#Destroy and undefining a VM and deleting the image 
echo "Destroying and Undefining $1"
virsh destroy $1
virsh undefine $1
rm -rf /home/admin/Code/VM/$1.img






