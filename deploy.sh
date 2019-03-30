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
		echo "$1 not initialized"	
	exit 0
fi


VMname=$2


fVMstate() {
	VMstate=`gcloud compute instances list | grep -E "^$VMname\s.*" | awk '{print $NF}'`
	if [ "$VMstate" == "RUNNING" ]
		then
		VMip=`gcloud compute instances list | grep -E "^$VMname\s.*" | awk '{E=NF-1}{print $E}'`
		VMssh="ssh -i /root/.ssh/gcp appuser@"$VMip
		return 0
	else
		return 1
	fi
}


#проверяем старт ВМ
if fVMstate
    then echo $VMip
    else echo "$GCproj:$VMname is not runnig"; exit 0
fi


#Ждем доступ на 22 порт
until nc -vzw 2 $VMip 22; do sleep 1; done


#Подключаемся к ВМ и устанавливаем ПО
$VMssh 'cd ~;
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

