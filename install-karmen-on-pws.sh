#!/bin/bash
# Adds karmen on PWS printer (Klipper firmware, systemd based on debian)
#
# Run following command on printer to install:
# curl -s https://raw.githubusercontent.com/fragaria/karmen-gists/v0.0.5/install-karmen-on-pws.sh | sudo -E bash -xs DEVICE_KEY

set -e  # exit on error
set -u  # error on undefined

DEVICE_KEY="${1:-}"

if [ "$DEVICE_KEY" = "" ]; then
    echo "Missing device key parameter."
    exit 255
fi


# NodeJS
curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E /bin/bash - && sudo apt install nodejs -y

# Websocket Proxy
curl -s https://raw.githubusercontent.com/fragaria/karmen-gists/v0.0.6/ws-install.sh | sudo -E bash -xs "$DEVICE_KEY"

# karmen-pws-connector
curl -s https://raw.githubusercontent.com/fragaria/karmen-pws-connector/v0.0.4/install.sh | sudo -E bash -xs

