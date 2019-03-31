#!/bin/bash

echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list;
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 &>/dev/null;
sudo apt update;
sudo apt install -y mongodb-org;
sudo systemctl enable mongod;
sudo systemctl start mongod;
sudo systemctl status mongod;
sudo netstat -tlp;
mongod --version;

