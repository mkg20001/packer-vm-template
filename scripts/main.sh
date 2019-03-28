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

cd "/usr/lib/$VM_NAME"

# fix git url, ci sometimes sets it to something else
git remote set-url origin "https://github.com/mkg20001/$VM_NAME.git"
# checkout to master, but without pulling yet
git checkout -b master
git fetch
git branch master -u origin/master

# run generated deployment
bash /tmp/provision/deploy.sh


if [ -e scripts/main.sh ]; then # if we have a main script
  bash scripts/main.sh # then run it
fi

