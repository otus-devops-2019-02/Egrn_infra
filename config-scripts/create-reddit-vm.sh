#!/bin/bash

#проверяем количество параметров запуска
if [ $# -lt 2 ] ; then echo "need params: $0 [project-name] [new-VM-name] ([abs-path-to-startup-script] optional)"
	exit 0
fi

#проверяем проект
GCproj=`gcloud info | grep project | sed -E 's/.*\[(.*)\].*/\1/g'`
if [ "$GCproj" == "$1" ]
	then
		echo "GCProj: $GCproj" 
	else
		echo "$GCproj not initialized"	
	exit 0
fi


VMname=$2


#Создаем VM	
gcloud compute instances create $VMname \
	--zone=us-west1-b \
	--boot-disk-size=11GB \
	--image reddit-full-1554147977 \
	--image-project=$1 \
	--machine-type=g1-small \
	--tags puma-server \
	--restart-on-failure


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
until fVMstate; do sleep 1; done


#Ждем доступа на 22 порт
until nc -vzw 2 $VMip 22; do sleep 1; done


#Чистим прежние записи о хосте
ssh-keygen -f "/root/.ssh/known_hosts" -R $VMip

#Обходим проверку подлиности
ssh -o "StrictHostKeyChecking=no" appuser@$VMip 'exit'


#Подключаемся к ВМ
$VMssh 'uname -a;
 hostname;
 curl -s ifconfig.me;
 exit; exit'


#Проверяем на наличие пути к стартап-скрипту и добавляем его в метадата, после чего ребут машины
if [ -n "$3" ]
	then
		gcloud compute instances add-metadata $VMname --metadata-from-file startup-script=$3
		$VMssh 'sudo reboot'
fi


exit 0


