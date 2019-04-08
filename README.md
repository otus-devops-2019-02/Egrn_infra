# Egrn_infra
## HW08: terraform-1

#### Задача
1. Определить input переменные для приватного ключа и зоны
2. terraform fmt
3. terraform.tfvars.example
#### Решение
done
___
#### Задача *
Опишите в коде добавление ssh ключа пользователя appuser1 в метаданные проекта. 
#### Решение *
Для разнообразия добавил в метаданные инстанса, несмотря на обратную рекомендацию этого. Работает
```
metadata {
    ssh-keys = "appuser1:${replace(file(var.public_key_path),"appuser",appuser1)}
    }
```
___
#### Задача **
Опишите в коде добавление нескольких ssh ключей для пользователей appuser* в метаданные проекта.
#### Решение **
Попытался использовать count для ресурса metadata или metadata_item и переменную тип list. Ожидание: ТФ идет по списку значений из переменной и, используя очередное значение, создает соответствующий metadata.ssh-keys. Результат получился неоднозначный. ТФ успешно создает все метаданные, но, так как в ресурсе metadata* отсутствует возможность задать id метадата (только key,value ), то все создаваемые metadata идентифицируются одним и тем же значением - по имени (key). То есть, первый созданный ключ перезаписывается пока не кончится count. 
```
resource "google_compute_project_metadata_item" "default" {
    count = "${length(var.users)}"
        key   = "ssh-keys"
        value = "${element(var.users,count.index)}:${replace(file(var.public_key_path),"appuser",element(var.users,count.index))}"
}

variable "users" {
  type        = "list"
  description = "Users ssh"
  default [ "appuser","appuser-one","appuser-two","appuser-web" ]
}
```
```bash
$ terraform show
google_compute_project_metadata_item.default.0:
  id = ssh-keys
  key = ssh-keys
  value = appuser:ssh-rsa ...

google_compute_project_metadata_item.default.1:
  id = ssh-keys
  key = ssh-keys
  value = appuser-one:ssh-rsa ...
```
Вероятно, мог бы помочь функционал foreach, но он недоступен в 0.11

Пришлось создавать с ручным указанием индекса значения в списке переменной:
```
metadata {
	ssh-keys = "${var.users[0]}:${replace(file(var.public_key_path),"appuser",var.users[0])}${var.users[1]}:${replace(file(var.public_key_path),"appuser",var.users[1])}"
	}
``` 
__

#### Задача ***
Создайте файл lb.tf и опишите в нем в коде terraform создание HTTP балансировщика, направляющего трафик на наше развернутое приложение на инстансе reddit-app
#### Решение ***
Все усепешно создал. Балансировку проверил, в том числе при отключении одной из машин. Output успешно обрабатывает все ip.
Для балансировщика использовал ресурс google_compute_target_pool c указанием группы конкретных инстансов. Сразу реализовал создание инстансов через count.
Заначения списка инстансов пула пришлось определить вручную. При попытке определять инстансы через переменную типа lis, столкнулся со сложностью в том, что при определении массива instances google_compute_target_pool не смог задать список через переменную типа list.
Не нашел как в ресурсе google_compute_target_pool сослаться на count.index ресурса google_compute_instance.
Хотел бы реализовать вот так:
```
resource "google_compute_target_pool" "reddit-app-pool" {
  name   = "reddit-app-pool"
  region = "${var.region}"
  
  instances = ["${var.zone}/${element(var.instances,<полный адрес count для google_compute_instance>)"]
  
  health_checks = [
    "${google_compute_http_health_check.reddit-app-healthcheck.name}",
  ]
}

```



___


## HW07_PACKER packer-base
#### Задачи
1. Парметризация шаблона packer
2. Определение переменных в отдельном файле
3. Дополнительный опции builder googlecompute
#### Результат
1. ./packer/ubuntu16.json
2. ./packer/variables.json.example
3. ./packer/ubuntu16.json
___

#### Задача *
Запечь в образ VM все зависимости приложения и сам код приложения. Результат должен быть таким: запускаем инстанс из созданного образа и на нем сразу же имеем запущенное приложение.
#### Результат
- Создан шаблон ./packer/immutable.json , который использует три провиженера: два из ./scripts/*.sh и один из ./files/*.sh , а также переменные из ./files/variables.json
- C помощью immutable.json успешно создан образ, включающий ruby,mongo,puma и стартующий puma через systemd
___

#### Задача *
Создание ВМ с помощью скрипта, использующего ранее созданный образ ОС по шаблону immutable.json
#### Результат
Скрипт ./config-scripts/create-reddit-vm.sh использует образ, в результате установки которого сразу доступен сервис ip:9292
___

## HW06_GCP2 cloud-testapp

#### Задача Скрипты
Команды по настройке системы и деплоя приложения нужно завернуть в баш скрипты
#### Решение
Рабочие скрипты:
- ./creat-vm.sh
- ./install_all.sh

Скрипты для проверок:
- ./install_ruby.sh
- ./install_mongodb.sh
- ./deploy.sh

#### Результат

```bash
testapp_IP = 35.228.57.135
testapp_port = 9292
```

_

#### Задача * Starup-script
В качестве доп. задания используйте созданные ранее скрипты для создания , который будет запускаться при создании инстанса.
Передавать startup скрипт необходимо как дополнительную опцию уже использованной ранее команде gcloud

#### Решение
Воспользуемся возможностью добавления метаданных к уже запущенной машине
```bash
gcloud compute instances add-metadata $VMname --metadata-from-file startup-script=/path-to-file/...
gcloud compute instances reset $VMname
```

#### Результат
- Скрипт: ./startup-script.sh
- Успешно созданная и настроенная ВМ: 35.228.54.204

_

#### Задача * Firewall rule
Удалите созданное через веб интерфейс правило для работы приложения default-puma-server. Создайте аналогично е правило из консоли с помощью gcloud.

#### Решение
```bash
gcloud compute firewall-rules create puma-server --allow tcp:9292 --target-tags=puma-server
```

#### Результат
Cетевая связность:
```bash
curl 35.228.57.135:9292
curl 35.228.54.204:9292
```

___


## HW05_GCP1 cloud_bastion

#### Задача SSH

Научиться доступу к someinternalhost в одну строку, но еще лучше, сразу по яльясу.

#### Решение

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

#### Для проверки

```bash
bastion_IP = 35.228.38.144
someinternalhost_IP = 10.166.0.3
```
_


#### Задача SSL

С помощью сервисов / и реализуйте использование валидного сертификата для панели управления VPN-сервера

#### Решение

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

