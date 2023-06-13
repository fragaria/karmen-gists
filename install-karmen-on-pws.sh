#!/bin/bash
# Adds karmen on PWS printer (Klipper firmware, systemd based on debian)

set -e  # exit on error


# NodeJS
curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash - && sudo apt install nodejs -y

# Websocket Proxy
curl -s https://raw.githubusercontent.com/fragaria/karmen-gists/v0.0.5/ws-install.sh | sudo bash -s KEY

# karmen-pws-connector
curl -s https://raw.githubusercontent.com/fragaria/karmen-pws-connector/v0.0.1/install.sh | exec bash -xs

