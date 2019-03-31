#!/bin/bash

#проверяем количество параметров запуска
if [ $# -lt 2 ]
	then
		echo "need params: $0 [project-name] [excited-VM-name]"
		exit 0
fi


#проверяем проект
GCproj=`gcloud info | grep project | sed -E 's/.*\[(.*)\].*/\1/g'`
if [ "$GCproj" == "$1" ]
	then
		echo "GCProj: $GCproj" 
	else
		echo "$1 are not initialized"	
	exit 0
fi


VMname=$2


fVMstate() {
	VMstate=`gcloud compute instances list | grep -E "^$VMname\s.*" | awk '{print $NF}'`
	if [ "$VMstate" == "RUNNING" ]
		then
			VMip=`gcloud compute instances list | grep "^$VMname\s.*" | awk '{E=NF-1}{print $E}'`
			VMssh="ssh -i /root/.ssh/gcp appuser@"$VMip
	fi
}


#Ждем готовность ВМ
until fVMstate; do sleep 1 ; done


#Ждем доступа на 22 порт
until nc -vzw 3 $VMip 22; do sleep 1 ; done


#Подключаемся к ВМ и устанавливаем ПО
$VMssh 'sudo apt update; 
 sudo apt install -y ruby-full ruby-bundler build-essential; 
 ruby -v; 
 bundler -v; 
 echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list;
 sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 &>/dev/null;
 sudo apt update;
 sudo apt install -y mongodb-org;
 sudo systemctl enable mongod;
 sudo systemctl start mongod;
 sudo systemctl status mongod;
 sudo netstat -tlp;
 mongod --version;
 cd ~;
 rm -fr ./reddit;
 git clone -b monolith https://github.com/express42/reddit.git;
 cd ./reddit;
 bundle install;
 sudo puma -d;
 exit'


#Открываем доступ к порту 9292
gcloud compute firewall-rules create puma-server --allow tcp:9292 --target-tags=puma-server


#Проверяем доступность приложения
curl -s $VMip:9292 | grep "title"


exit 0
