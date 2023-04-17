# Instalační instrukce

## Instalace nodejs

`curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash - && sudo apt install nodejs -y`

dá se ověřit pomocí 

`node -v`

## moonraker-spectoda-node

### Instalace moonraker-spectoda-connector

Na zařízení vytvořit `install.sh` a do něj nakopírovat:

```
#!/bin/bash

sudo -v

NU=$(logname)

cd /home/pi/

sudo -u $NU git clone https://github.com/fragaria/moonraker-spectoda-connector.git
cd /home/pi/moonraker-spectoda-connector
sudo -u $NU npm ci

content='[Unit]
Description=Bridge for connecting to Moonraker events Spectoda REST API
After=network.target

[Service]
User=pi
Group=pi
WorkingDirectory=/home/pi/moonraker-spectoda-connector
ExecStart=node index.js
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=default.target'

# create the service file
echo "$content" |  tee /etc/systemd/system/moonraker-spectoda-connector.service > /dev/null

# reload the daemon
systemctl daemon-reload

# enable the service
systemctl enable --now moonraker-spectoda-connector
```

pak `chmod +x install.sh` a `sudo ./install.sh`

po instalaci by:
- v `/home/pi/moonraker-spectoda-connector` by měl být vyklonovaný repozitář
- měl by existoval soubor `/etc/systemd/system/moonraker-spectoda-connector.service` 
- `sudo systemctl status moonraker-spectoda-connector.service` by měl zobrazovat `Active: active (running)`

### Aktualizace moonraker-spectoda-connector

do `/home/pi/printer_data/config/moonraker.conf` přidat:

```
[update_manager moonraker-spectoda-connector]
type: git_repo
path: ~/moonraker-spectoda-connector
origin: https://github.com/fragaria/moonraker-spectoda-connector.git
primary_branch: main
enable_node_updates: True
managed_services:
    moonraker-spectoda-connector
```

## websocket-proxy

### Instalace websocket-proxy

Na každém zařízení spustit (KEY nahradit karmen key):
`curl -s https://raw.githubusercontent.com/fragaria/karmen-gists/main/ws-install.sh | sudo bash -s KEY`

pro ověření:
`sudo systemctl status websocket-proxy.service`

### Aktualizace websocket-proxy

do `/home/pi/printer_data/config/moonraker.conf` přidat:

```
[update_manager websocket-proxy]
type: git_repo
path: ~/websocket-proxy
origin: https://github.com/fragaria/websocket-proxy.git
enable_node_updates: True
managed_services:
    websocket-proxy
```


