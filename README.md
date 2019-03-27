# Egrn_infra
Egrn Infra repository

№# HW05_GCP1 cloud_bastion

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

2. Запуск с рабочего места теперь осущестляется по альясам

```bash
ssh bastion
```

```bash
ssh someinternalhost 
```

### Для проверки
bastion_IP = 35.228.38.144
someinternalhost_IP = 10.166.0.3


## Задача SSL

С помощью сервисов / и реализуйте
использование валидного сертификата для панели управления
VPN-сервера

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


