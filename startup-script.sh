#!/bin/bash

sudo apt update;
sudo apt install -y ruby-full ruby-bundler build-essential;
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" |
sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list;
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927;
sudo apt update;
sudo apt install -y mongodb-org;
sudo systemctl enable mongod;
sudo systemctl start mongod;
cd ~;
rm -fr ./reddit;
git clone -b monolith https://github.com/express42/reddit.git;
cd ./reddit;
bundle install;
sudo puma -d;

