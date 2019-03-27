#!/bin/bash

_module() {
  . "$SHARED/modules/$1.sh"
}

i() {
  echo "[*] $*"
}

o() {
  echo "[!] $*"
}
