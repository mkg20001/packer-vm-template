#!/bin/bash

set -e

MAIN=$(dirname $(dirname $(dirname $(readlink -f $0))))

self() {
  echo "[*] Einspielen der Aktualisierung..."
  apt update
  apt dist-upgrade -y

  echo "[*] Aufräumen..."
  apt-get autoremove -y
  apt-get clean

  purgelist=`echo $(dpkg -l | awk '$1 == "rc" { print $2; }')`
  if [ ! -z "$purgelist" ]; then
    echo "[*] Entfernen von unbenötigten Paketdaten ($purgelist)..."
    apt-get remove --purge $purgelist -y
  fi

  cd "$MAIN"
  git pull --recurse-submodules
  git gc --aggressive
  bash shared/scripts/update.sh

  exit 0
}

self
