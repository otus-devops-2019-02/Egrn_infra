# Egrn_infra

## HW06_GCP2 cloud-testapp

## Задача Скрипты
Команды по настройке системы и деплоя приложения нужно завернуть в баш скрипты

### Решение

Рабочие скрипты:
~./creat-vm.sh
~./install_all.sh

Скрипты для проверок:
~./install_ruby.sh
~./install_mongodb.sh
~./deploy.sh

### Результат

```bash
testapp_IP = 35.228.57.135
testapp_port = 9292
```

_


## Задача * Starup-script
В качестве доп. задания используйте созданные ранее скрипты для создания , который будет запускаться при создании инстанса.
Передавать startup скрипт необходимо как дополнительную опцию уже использованной ранее команде gcloud

### Решение
Воспользуемся возможностью добавления метаданных к уже запущенной машине

bash```
gcloud compute instances add-metadata $VMname --metadata-from-file startup-script=/path-to-file/...
gcloud compute instances reset $VMname
```

### Результат
~Скрипт: ./startup-script.sh
~Успешно созданная и настроенная ВМ: 35.228.54.204

_

## Задача * Firewall rule
Удалите созданное через веб интерфейс правило для работы приложения default-puma-server. Создайте аналогично е правило из консоли с помощью gcloud.

### Решение

bash```
gcloud compute firewall-rules create puma-server --allow tcp:9292 --target-tags=puma-server
```

### Результат
Cетевая связность:

bash```
curl 35.228.57.135:9292
curl 35.228.54.204:9292
```

___



## HW05_GCP1 cloud_bastion

## Задача SSH

Научиться доступу к someinternalhost в одну строку, но еще лучше, сразу по яльясу.

### Решение

1. Добавляем в ~/.ssh/config

```bash
Host bastion
    Hostname 35.228.38.144
    User appuser
    IdentityFile ~/.ssh/gcp

Host someinternalhost
    Hostname 10.166.0.3
    User appuser
    IdentityFile ~/.ssh/gcp
    ProxyCommand ssh -W %h:%p bastion
```

2. Запуск с рабочего места теперь осуществляется по альясам

```bash
ssh bastion
```

```bash
ssh someinternalhost 
```

### Для проверки

```bash
bastion_IP = 35.228.38.144
someinternalhost_IP = 10.166.0.3
```

## Задача SSL

С помощью сервисов / и реализуйте использование валидного сертификата для панели управления VPN-сервера

### Решение

1. Используем DNS подсиcтему, чтобы получить резолв доменного имени в целевой адрес, не прибегая к регистрации имени
```bash
nslookup 35-228-38-144.sslip.io
```

2. Идем на gui pritunl-web -> Settings -> Lets Encrypt Domain -> 35-228-38-144.sslip.io

3. Рестартуем сервер
```bash
service pritunl restart
```

4. Проверяем сертификат
```bash
true | openssl s_client -showcerts -connect 35-228-38-144.sslip.io:443 | openssl x509 -text | head -10
```


