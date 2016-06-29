#!/bin/bash

DISKIMG_DIR='/home/admin/Code/VM'

ARCH=x86_64
NUM_CPU=1
MEMORY=4096
DISKSIZE=20G
DISKFORMAT=qcow2
PASSWORD=practice1234

if [ -z "$1" ]; then
  echo "Name must be specified!"
  usage
fi

if [ -n "$3" ]; then
  RELEASE=$2
else
  RELEASE=6
fi

NAME=$1
DISK=$DISKIMG_DIR/$NAME.img
LOCATION=/home/admin/Code/VM/ISO/rhel-server-7.2-x86_64-dvd.iso
KSFILE=/tmp/ks-$$.cfg

if [ -z "$PASSWORD" ]; then
  PASSWORD=$NAME
fi

function create_image() {
  if [ ! -f $DISK ]; then
    qemu-img create -f $DISKFORMAT $DISK $DISKSIZE
  else
    echo "$DISK already exists. Please remove it first."
    exit 1
  fi
}

function generate_kickstart_config() {
  local url
  echo "url: $LOCATION"
  url="--url=$LOCATION"
  if [ -n "$PROXY" ]; then
    url+=" --proxy=$PROXY"
  fi

  cat > $KSFILE <<EOF
install 
lang en_US
keyboard us
network --bootproto=dhcp
timezone America/New_York --isUtc
rootpw practice1234
#platform x86, AMD64, or Intel EM64T
cdrom
text
url $url
bootloader --location=mbr --append="rhgb quiet crashkernel=auto"
zerombr
clearpart --all --initlabel
autopart
auth --passalgo=sha512 --useshadow
selinux --enforcing
firewall --enabled --http --ftp --ssh --port=389,636,9830
skipx
firstboot --disable
%packages --default
@base
%end
EOF
}

function virt_install() {
  sudo virt-install \
    --name $NAME \
    --virt-type kvm \
    --ram $MEMORY \
    --vcpus $NUM_CPU \
    --arch $ARCH \
    --os-type linux \
    --os-variant rhel6 \
    --boot hd \
    --disk $DISK,format=$DISKFORMAT,bus=virtio \
    --network network=default,model=virtio \
    --serial pty \
    --console pty \
    --location $LOCATION \
    --initrd-inject $KSFILE \
    --extra-args "ks=file:/`basename $KSFILE` console=ttyS0,115200" \
    --network bridge=virbr0 \
    --nographics

    #--graphics vnc \
    #--noautoconsole \

    
}

function cleanup() {
  rm -v $KSFILE
}

create_image
generate_kickstart_config
virt_install
cleanup


