#!/bin/bash

_module() {
  . "$SHARED/modules/$1.sh"
}

i() {
  echo "[*] $*"
}

d() {
  echo "[!] $*"
}

function contains() {
  match="$1"
  shift
  for e in "$@"; do
    if [ "$e" == "$match" ]; then
      return 0
    fi
  done
  return 1
}

