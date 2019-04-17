#!/bin/bash

for i in `gcloud compute instances list | sed 1d | awk '{E=NF-1}{print $E}'`
	do
		until nc -vzw 2 $i 22; do sleep 1; done	#Ждем доступа на 22 порт

		ssh-keygen -f "/root/.ssh/known_hosts" -R $i	#Чистим прежние записи о хосте

		ssh -o "StrictHostKeyChecking=no" appuser@$i 'exit'	#Обходим проверку подлиности
done