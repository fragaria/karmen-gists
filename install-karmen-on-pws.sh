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
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update
sudo apt-get install nodejs -y

# Websocket Proxy
curl -s https://raw.githubusercontent.com/fragaria/karmen-gists/v0.0.6/ws-install.sh | sudo -E bash -xs "$DEVICE_KEY"

# karmen-pws-connector
curl -s https://raw.githubusercontent.com/fragaria/karmen-pws-connector/v0.0.4/install.sh | sudo -E bash -xs

