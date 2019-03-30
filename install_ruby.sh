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
 exit; exit'


exit 0
