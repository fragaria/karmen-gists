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
cd $USER_HOME
sudo -u $NU git clone --depth 1 https://github.com/fragaria/websocket-proxy.git
cd $USER_HOME/websocket-proxy/
# sudo -u $NU mv websocket-proxy-master/* .
# sudo -u $NU rm -rf websocket-proxy-master
sudo -u $NU npm install --only=production

# create systemd service file
CONFFILE=$USER_HOME/printer_data/config/websocket-proxy.conf
sudo -u $NU cat >$CONFFILE <<EOF
KARMEN_URL=https://karmen.fragaria.cz
NODE_ENV=production
PATH=/bin
FORWARD_TO=http://127.0.0.1
KEY=$KEY
SERVER_URL=wss://cloud.karmen.tech
FORWARD_TO_PORTS=80,8888
EOF

# create systemd websocket-proxy service
cat >/etc/systemd/system/websocket-proxy.service <<EOF
[Unit]
Description=Karmen websocket proxy tunnel client
Wants=network-online.target
After=network.target network-online.target
[Service]
ExecStart=node client
Restart=always
RestartSec=1
User=$USER
Group=$GROUP
Environment=PATH=/usr/bin:/usr/local/bin
EnvironmentFile=$CONFFILE
WorkingDirectory=$USER_HOME/websocket-proxy
[Install]
WantedBy=multi-user.target
EOF

# setup Karmen printer key (necessary for ws proxy to be able to connect
WS_KEY_FILE=$USER_HOME/printer_data/config/karmen-key.txt
if [ ! -f  $WS_KEY_FILE ]; then
    sudo -u $NU cat >$WS_KEY_FILE <<EOF
    $KEY
EOF
fi

# setup moonraker uuuu
sudo -u $NU cat >>$USER_HOME/printer_data/config/moonraker.conf <<EOF
[update_manager websocket-proxy]
type: git_repo
path: ~/websocket-proxy
origin: https://github.com/fragaria/websocket-proxy.git
enable_node_updates: True
managed_services:
    websocket-proxy
EOF

# allow moonraker to manage websocket-proxy systemd service
MOONSVC=$USER_HOME/printer_data/moonraker.asvc
if ! cat $MOONSVC | grep websocket-proxy > /dev/null; then
        echo "websocket-proxy" >> $MOONSVC
    else
        echo "Websocket already enabled!";
fi

chmod 755 $USER_HOME/

systemctl daemon-reload
systemctl enable websocket-proxy.service
systemctl restart websocket-proxy.service

curl -s https://raw.githubusercontent.com/fragaria/karmen-pws-connector/v0.0.1/install.sh | exec bash -xs
