#!/bin/bash
set -e

APP_DIR=${1:-$HOME}

if [ `systemctl show -p ActiveState puma | sed 's/ActiveState=//g'` == "active"  ]; then
	exit 0
fi


git clone -b monolith https://github.com/express42/reddit.git $APP_DIR/reddit
cd $APP_DIR/reddit
bundle install

echo -e "[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/home/appuser/reddit
ExecStart=/bin/bash -lc 'puma'
Restart=always

[Install]
WantedBy=multi-user.target

"| sudo tee /lib/systemd/system/puma.service
sudo systemctl enable puma.service

