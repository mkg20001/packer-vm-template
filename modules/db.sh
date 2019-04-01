#!/bin/bash

init_db() {
  DB="$1"
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
  if [[ "$DB" == "/tmp/"* ]]; then
    rm -f "$DB"
  fi
  init_db "$DB_OLD"
}

_db_get() { # TODO: throw on empty
  export $(echo "$1" | tr "[:lower:]" "[:upper:]" | sed "s|\\.|_|g")="$(_db $1)"
}

_db_exists() {
  ex=0
  (cat "$DB" | grep "^$1=" >/dev/null) || ex=$?
  return $ex
}
