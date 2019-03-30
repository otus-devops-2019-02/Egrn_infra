#!/bin/bash

cd ~;
rm -fr ./reddit;
git clone -b monolith https://github.com/express42/reddit.git;
cd ./reddit;
bundle install;
sudo puma -d;


