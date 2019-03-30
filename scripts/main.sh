#!/bin/bash

set -ex

# update
apt-get update
apt-get dist-upgrade -y
apt-get clean

# get bundle
cd /tmp
tar xvfz bundle.tar.gz
rm bundle.tar.gz
cd provision

# setup local repo
tar xvfz "git.tar.gz"
git clone --recursive /tmp/provision/.git "/usr/lib/$VM_NAME"

# set keyboard to german
loadkeys de
localectl set-keymap de
dpkg-reconfigure locale

cd "/usr/lib/$VM_NAME"

# fix git url, ci sometimes sets it to something else
git remote set-url origin "https://github.com/mkg20001/$VM_NAME.git"
# checkout to master, but without pulling yet
git checkout -b master
git fetch
git branch master -u origin/master

# fetch infra
mkdir node_modules
git clone https://github.com/mkg20001/mkg-infra node_modules/mkg-infra

# run generated deployment
bash /tmp/provision/deploy.sh

if [ -e scripts/main.sh ]; then # if we have a main script
  bash scripts/main.sh # then run it
fi


## CLEANUP ##

cd /
SSH_USER=${SSH_USERNAME:-vmadmin}

echo "==> Cleaning up tmp"
rm -rf /tmp/*

# Cleanup apt cache
apt-get -y autoremove --purge
apt-get -y clean

echo "==> Installed packages"
dpkg --get-selections | grep -v deinstall

# Remove Bash history
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/${SSH_USER}/.bash_history

echo "==> Clearing log files"
find /var/log -type f -exec truncate --size=0 {} \;

echo '==> Clear out swap and disable until reboot'
set +e
swapuuid=$(/sbin/blkid -o value -l -s UUID -t TYPE=swap)
case "$?" in
    2|0) ;;
    *) exit 1 ;;
esac
set -e
if [ "x${swapuuid}" != "x" ]; then
    # Whiteout the swap partition to reduce box size
    # Swap is disabled till reboot
    swappart=$(readlink -f /dev/disk/by-uuid/$swapuuid)
    /sbin/swapoff "${swappart}"
    dd if=/dev/zero of="${swappart}" bs=1M || echo "dd exit code $? is suppressed"
    /sbin/mkswap -U "${swapuuid}" "${swappart}"
fi

# Zero out the free space to save space in the final image
dd if=/dev/zero of=/EMPTY bs=1M || echo "dd exit code $? is suppressed"
rm -f /EMPTY
sync

echo "==> Disk usage after cleanup"
df -h
