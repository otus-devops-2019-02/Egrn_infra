#!/bin/bash
set -e

cd ~
rm -fr ./reddit
git clone -b monolith https://github.com/express42/reddit.git
cd ./reddit
bundle install
echo -e "[Unit]
Description=Puma HTTP Server
After=mongod.service
[Service]
Type=forking
WorkingDirectory=/home/appuser/reddit
ExecStart=/usr/local/bin/puma -d
StandardError=journal
StandardOutput=null
Restart=always
PIDFile=/var/run/puma.pid
[Install]
WantedBy=multi-user.target

"| sudo tee /lib/systemd/system/puma.service
sudo systemctl enable puma.service

