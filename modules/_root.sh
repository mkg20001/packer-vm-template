#!/bin/bash

if [ $(id -u) -gt 0 ]; then
  echo "FEHLER: Dieser Befehl muss als Benutzer root ausgeführt werden. Verwenden Sie bitte stattdessen 'sudo $CMD'" >&2
  exit 2
fi
