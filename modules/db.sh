#!/bin/bash

init_db() {
  if [ ! -e "$DB" ]; then
    mkdir -p "$(dirname $DB)"
    touch "$DB"
  fi
}

_db() { # GET <key> SET <key> <value>
  if [ -z "$2" ]; then
    cat "$DB" | grep "^$1=" | sed "s|$1=||g" || /bin/true
  else
    newdb=$(cat "$DB" | grep -v "^$1=" || /bin/true)
    newdb="$newdb
$1=$2"
    echo "$newdb" > "$DB"
  fi
}

pushdb() {
  if [ -z "$1" ]; then
    set -- "/tmp/$$$RANDOM"
  fi
  DB_OLD="$DB"
  init_db "$1"
}

popdb() {
  rm -f "$DB"
  init_db "$DB_OLD"
}

_db_get() {
  set $(echo "$1" | tr "[:lower:]" "[:upper:]")="$(_db $1)"
}

_db_exists() {
  ex=0
  cat "$DB" | grep "^$1=" | sed "s|$1=||g" > /dev/null || ex=$?
  return $ex
}
