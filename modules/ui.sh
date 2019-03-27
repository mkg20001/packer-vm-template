#!/bin/bash

prompt() {
  KEY="$1"
  PROMPT="$2"
  CUR=$(_db "$KEY")
  NEW=""

  if [ -z "$CUR" ] && [ ! -z "$3" ]; then
    CUR="$3" # use $3 as default
  fi

  # TODO: typevalidation

  while [ -z "$NEW" ]; do
    if [ ! -z "$CUR" ]; then
      read -p "> $PROMPT (aktueller wert '$CUR', leer lassen um beizubehalten): " NEW
      if [ -z "$NEW" ]; then
        NEW="$CUR"
      fi
    else
      read -p "$PROMPT: " NEW
    fi
  done

  echo "< $NEW"

  _db "$KEY" "$NEW"
  _db_get "$KEY"
}

