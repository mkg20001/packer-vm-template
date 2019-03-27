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
git clone /tmp/provision/.git "/usr/lib/$VM_NAME"

# run generated deployment
bash deploy.sh

# set keyboard to german
loadkeys de
localectl set-keymap de

