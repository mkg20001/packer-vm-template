#!/bin/bash

set -e

echo "[*] Ausführen der Update-Routine..."

# because npm
export SUDO_GID=
export SUDO_COMMAND=
export SUDO_USER=
export SUDO_UID=
export HOME=/root

# rm node modules and re-install
rm -rf node_modules package-lock.json
npm i
# generate script and deploy
./node_modules/.bin/dpl-tool deploy.yaml | bash -

if [ -e scripts/update.sh ]; then
  bash scripts/update.sh
fi
