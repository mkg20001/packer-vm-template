#!/bin/bash

VM_NAME="$1"

hostname "$VM_NAME"
echo "$VM_NAME" > /etc/hostname

LIB="/usr/lib/$VM_NAME"
cd "$LIB"

apt-get update
apt-get dist-upgrade -y
apt-get install -y openssh-server git net-tools open-vm-tools gnupg2

bash deploy.sh

if [ -e scripts/main.sh ]; then
  mv scripts/main.sh
fi

bash shared/scripts/update.sh
