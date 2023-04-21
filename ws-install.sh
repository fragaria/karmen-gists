#!/bin/bash

# bash script that downloads and installs karmen websocket-proxy
# download latest release from https://github.com/fragaria/websocket-proxy/
# and install it to /home/pi/websocket-proxy

# check if nodejs is installed
# install nodejs if not installed
# download latest release and extract it to /home/pi/websocket-proxy
# create systemd service file for karmen websocket-proxy
# start karmen websocket-proxy

# Install nodejs first!
# curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash - && sudo apt install nodejs -y
# And then:
# curl -s https://raw.githubusercontent.com/fragaria/karmen-gists/main/ws-install.sh | sudo bash -s KEY

if [ ${EUID} -ne 0 ]; then
    echo "This script must be run as root. Cancelling" >&2
    exit 1
fi

if [ -z "$1" ]
then
      echo "No karmen key provided. Use ./install.sh <key>"
      exit 1
fi

KEY=$1
echo ""
sudo -v

NU=$(logname)

USER_HOME=$(bash -c "cd ~$(printf %q "$NU") && pwd")
GROUP=($(groups))

# download latest release

# sudo -u $NU curl -L -o /tmp/websocket-proxy.zip https://github.com/fragaria/websocket-proxy/archive/refs/heads/master.zip
# sudo -u $NU mkdir $USER_HOME/websocket-proxy
# sudo -u $NU unzip -o /tmp/websocket-proxy.zip -d $USER_HOME/websocket-proxy
sudo -u $NU git clone --depth 1 https://github.com/fragaria/websocket-proxy.git
cd $USER_HOME/websocket-proxy/
# sudo -u $NU mv websocket-proxy-master/* .
# sudo -u $NU rm -rf websocket-proxy-master
sudo -u $NU npm install --only=production

# create systemd service file
CONFFILE=/etc/websocket-proxy.conf
echo -n "" > $CONFFILE
echo "KARMEN_URL=https://karmen.fragaria.cz" >> $CONFFILE
echo "NODE_ENV=production" >> $CONFFILE
echo "PATH=/bin" >> $CONFFILE
echo "FORWARD_TO=http://127.0.0.1" >> $CONFFILE
echo "KEY=$KEY" >> $CONFFILE
echo "SERVER_URL=wss://cloud.karmen.tech" >> $CONFFILE

SERVICEFILE=/etc/systemd/system/websocket-proxy.service

echo -n "" > $SERVICEFILE
echo "[Unit]" >> $SERVICEFILE
echo "Description=Karmen websocket proxy tunnel client" >> $SERVICEFILE
echo "Wants=network-online.target" >> $SERVICEFILE
echo "After=network.target network-online.target" >> $SERVICEFILE
echo "[Service]" >> $SERVICEFILE
echo "ExecStart=node client" >> $SERVICEFILE
echo "Restart=always" >> $SERVICEFILE
echo "RestartSec=1000" >> $SERVICEFILE
echo "User=$USER" >> $SERVICEFILE
echo "Group=$GROUP" >> $SERVICEFILE
echo "Environment=PATH=/usr/bin:/usr/local/bin" >> $SERVICEFILE
echo "EnvironmentFile=$CONFFILE" >> $SERVICEFILE
echo "WorkingDirectory=$USER_HOME/websocket-proxy/" >> $SERVICEFILE
echo "[Install]" >> $SERVICEFILE
echo "WantedBy=multi-user.target" >> $SERVICEFILE

KEYFILE=$USER_HOME/printer_data/config/karmen-key.txt
echo -n "" > "$KEYFILE"
echo $KEY >> "$KEYFILE"

MOONCONF=$USER_HOME/printer_data/config/moonraker.conf
echo "" >> $MOONCONF
echo "[update_manager websocket-proxy]" >> $MOONCONF
echo "type: git_repo" >> $MOONCONF
echo "path: ~/websocket-proxy" >> $MOONCONF
echo "origin: https://github.com/fragaria/websocket-proxy.git" >> $MOONCONF
echo "enable_node_updates: True" >> $MOONCONF
echo "managed_services:" >> $MOONCONF
echo "    websocket-proxy" >> $MOONCONF

#chmod 755 $USER_HOME/

systemctl daemon-reload
systemctl enable websocket-proxy.service
systemctl restart websocket-proxy.service
