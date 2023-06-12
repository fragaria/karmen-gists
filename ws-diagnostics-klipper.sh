#!/bin/bash
#
# Author: Robin Gottfried @ fragaria.cz
#
# Runs a websocket-proxy installation diagnostics on a klipper machine.
# This script presumes that websocket-proxy was installed using ws-install.sh
# script in this repository.
#
# Run this script run following command on the printer:
# curl -s https://raw.githubusercontent.com/fragaria/karmen-gists/main/ws-diagnostics-klipper.sh | sudo bash -s

set -eu

declare -x MSG=""

PI_HOME=/home/pi
WS_DIR="$PI_HOME/websocket-proxy"
PRINTER_DATA="$PI_HOME/printer_data"

i() {
    echo "$*"
}

label() {
    MSG="$*"
}

passed() {
    i "$MSG ... OK"
}

failed() {
    i "$MSG ... Failed"
}

label is clonned
cd "$WS_DIR" && passed || failed

label npm is installed
node --version > /dev/null && passed || failed

echo -n "... node version: " && node --version

label repository exists
git status --porcelain && passed || failed
echo -n "... git hash: " && git rev-parse --short HEAD

label repository is clean
[ "$(git status --porcelain)" = "" ] && passed || failed

label service exists and is running
systemctl status websocket-proxy | grep running > /dev/null && passed || { 
    failed
    echo -n "... status is: " && systemctl status websocket-proxy | grep Active
}

echo Here are websocket-proxy log fragments
echo ======================================
# key should not be printed anyway, it's double protection
sudo journalctl -u websocket-proxy -g "exited|started|error"  |tail -10 | grep -vi key
