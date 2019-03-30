#!/bin/bash

ask_net() {
  fam_name="IPv$1"
  fam_id="ipv$1"
  prompt "$fam_id" "Adresse für $fam_name@$_NIC (* angeben um DHCP zu verwenden, - angeben um zu deaktivieren, format: 'ADDRESSE/MASKE')"
  if [ "$(_db $fam_id)" == "*" ]; then
    echo "[*] $fam_name@$_NIC wird auf DHCP geschaltet"
    CONF="$CONF
      dhcp$1: yes"
  elif [ "$(_db $fam_id)" == "-" ]; then
    echo "[*] $fam_name@$_NIC wird nicht konfiguriert"
    CONF="$CONF
      dhcp$1: no"
  else
    prompt "$fam_id.gateway" "Gateway für $fam_name"
    prompt "$fam_id.dns" "DNS Server für $fam_name"
    CONF="$CONF
      dhcp$1: no
      gateway$1: $(_db $fam_id.gateway)"
    _ADDR+=("$(_db $fam_id)")
    _DNS+=("$(_db $fam_id.dns)")
    echo "[*] $fam_name@$_NIC wird auf Addresse $(_db $fam_id) geschaltet"
  fi
}

ask_nic() {
  echo "[*] Netzwerkadapter:"
  ip -o link show | grep ": ens"
  NIC_NOT_SET=true
  while $NIC_NOT_SET; do
    prompt nic "Netzwerkadapter der verwendet werden soll"
    _NIC=$(_db nic)

    for nic in $(ip -j link show | jq -cr ".[] | .ifname" | grep "^ens"); do
      if [[ "$nic" == "$_NIC" ]]; then
        NIC_NOT_SET=false
      fi
    done
  done
}

setup_net() {
  if cat /etc/passwd | grep vagrant >/dev/null; then
    d "Vagrant"
    return 0
  fi

  ask_nic

  _ADDR=()
  _DNS=()

  CONF="network:
  version: 2
  renderer: networkd
  ethernets:
    $_NIC:"

  ask_net 4
  ask_net 6

  if [ ! -z "${_ADDR[*]}" ]; then
    CONF="$CONF
      addresses:"
    for _ADDR in "${_ADDR[@]}"; do
      CONF="$CONF
        - $_ADDR"
    done
  fi

  if [ ! -z "${_DNS[*]}" ]; then
    CONF="$CONF
      nameservers:
        addresses:"
    for _DNS in "${_DNS[@]}"; do
      CONF="$CONF
          - $_DNS"
    done
  fi

  echo "$CONF" > /etc/netplan/10-pssl.yaml

  echo "[*] Anwenden..."

  netplan apply
  service systemd-networkd restart

  echo "[*] Angewendet!"

  # TODO: connectivity check
}

