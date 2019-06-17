# Egrn_infra
[![Build Status](https://travis-ci.com/otus-devops-2019-02/Egrn_infra.svg?branch=master)](https://travis-ci.com/otus-devops-2019-02/Egrn_infra)
___

## HW13: ansinble-4

####Задачи
- Провиженинг ansible для vagrant инстансов
- Тестирование роли спомощью molecule на vagrant
- Переключение сбора образов packer на использование ролей

####Решение
Выполнено.
__

#### Задачи *1
Конфигурация Vagrant для корректной работы проксирования приложения с помощью nginx
#### Решение *1
В vagrant файл добавлено определение переменной default-site, предназначенной для роли jdauphant.nginx
Для обычного использования, переменные определены в environments group_vars

__
#### Задачи *2
Вынести роль db в отдельный репозиторий: удалить роль из репозитория infra и сделать подключение роли через requirements.yml обоих окружений;
#### Решение *2
Роль вынесена в https://github.com/Egrn/ansible-role-db
Роль устанавливается: ansible-galaxy install -r environments/prod/requirements.yml

__
#### Задачи *3
- Подключить TravisCI для созданного репозитория с ролью db для автоматического прогона тестов в GCE 
- Использовать бейдж билда
- Настроить оповещения о билде в слак
#### Решение *3
[![Build Status](https://travis-ci.org/Egrn_infra/ansible-role-db.svg?branch=master)](https://travis-ci.org/Egrn/db)


___
___
## HW12: ansinble-3

#### Задачи
- Переносим созданные плейбуки в раздельные роли
- Описываем два окружения
- Используем коммьюнити роль nginx
- Иcпользуем Ansible Vault для наших окружений
#### Решение
Выполнено.
___
#### Задачи *
Настройте использование динамического инвентори для окружений stage и prod
#### Решение
Дополнил скрипт формирования инвентаря функционалом генерации дополнительных инвентарей /ansible/environments/prod/inventory и /ansible/environments/stage/inventory.
Выполнено. Последовательность команд для применения.
```
terraform apply
...
make-inventory.sh -y
...
 ansible-playbook -i environments/stage/inventory playbooks/site.yml
...
```
#### Задачи **
Настройка проверок TravisCI:
- packer validate для всех шаблонов
- terraform validate и tflint для окружений stage и prod
- ansible-lint для плейбуков Ansible
- в README.md добавлен бейдж с статусом билда
#### Решение
Не стал использовать преподавательский docker контейнер, попробовал сделать окружением на ВМ travis. Отлаживал с помощью trytravis и отдельного репозитория.
Добавил инструкцию play-travis/mytravis.sh после .../run.sh в .travis.yml
Travis ориентируется на exit 0 скрипта, поэтому вывод отдельных проверок внутри скрипта парсить не стал.
[![Build Status](https://travis-ci.com/otus-devops-2019-02/Egrn_infra.svg?branch=ansible-3)](https://travis-ci.com/otus-devops-2019-02/Egrn_infra)

___
___


## HW11: ansinble-2

#### Задачи
- Конфигурация один файл - один сценарий
- Конфигурация один файл - несколько сценариев
- Конфигурация несколько файлов по одному сценарию
#### Решение
Выполнено.
___

#### Задача *
- Возможности использования dynamic inventory для GCP
- Отразить в ansible.cfg и плейбуках
#### Решение
Оставил прежний bash-скрипт dynamic inventory для GCP. Добавил обновление ip инстанса БД в переменные всех playbook. Добавил в ansible.cfg пользователя по умолчанию.
```
ansible-playbook site.yml -i make-inventory.sh
```
Результат успешен.
___
#### Задача *
Провиженинг ansible для packer
- ansible/packer_app.yml и ansible/packer_db.yml
- packer/app.json и packer/db.json
- Выполните билд образов с использованием нового провижинера.
- На основе созданных app и db образов запустите stage окружение.
#### Решение
Образы успешно сбилдились, stage на них поднялся, сценарии site.yml доконфигурили, приложение поднялось.
___
___
## HW10: ansinble-1

#### Задача
Знакомство с ansible, пара компанд, плейбук clone
#### Решение
Выполнено.

#### Задача *
Скрипт для генерации схемы json, исползуемый в качестве dynamic inventory
#### Решение
Выполнено.
Bash-скрипт получает данные из api gcloud: 
- с параметром --yaml генерирует корректные файлы inventory и inventory.yml.
- с параметром --list генерирует файл inventory.json и stdout
- с параметром --host <IP> генерирует stdout.

```
ansible group-name -i ./make-inventory.sh -m ping
ansible IP -i ./make-inventory.sh -m ping

```
Ансибл во всех случайх успешно парсит вывод, корректно получает список хостов группы, и выполняет команды

___
___

## HW09: terraform-2

#### Задача модули
0. Перейти на модули, создать модули, в том числе собственный /vpc.
1. Введите в source_ranges не ваш IP адрес, примените правило и проверьте отсутствие соединения к обоим хостам по ssh. Проконтролируйте, как изменилось правило файрвола в веб консоли.
2. Введите в source_ranges ваш IP адрес, примените правило и проверьте наличие соединения к обоим хостам по ssh.
3. Верните 0.0.0.0/0 в source_ranges.

#### Решение
Выполнено. Понято с наследованием инпутов и аутпутов. С доступом к ssh в зависимости от конфигурации поэкспериментирвоано - работает.
___
#### Задача Переиспользование
0. Создадим Stage & Prod
1. Удалите из папки terraform файлы main.tf, outputs.tf, terraform.tfvars, variables.tf, так как они теперь перенесены в stage и prod
2. Параметризируйте конфигурацию модулей насколько считаете нужным
3. Отформатируйте конфигурационные файлы, используя команду terraform fmt

#### Решение
Выполнено. Два окружения используют одни и те же модули, различаются только значением переменных.
___
#### Задача * удаленное хранение state
- Использовать модуль ресурса бакета от SweetOps 
- Настройте хранение стейт файла в удаленном бекенде для окружений stage и prod, используя Google Cloud Storage, описание в backend.tf

#### Решение
Выполнено. Модуль использован. Успешно инициализируются удаленные стейты, на время изменений появляется лок-файл. Оба стейта хранятся в одном бакете, с различными префиксами бекэнда.
___
#### Задача ** необходимые provisioner в модули для деплоя
1. Добавьте необходимые provisioner в модули для деплоя и работы приложения. Файлы, используемые в provisioner, должны находится в директории модуля.
2. Опционально можете реализовать отключение provisioner в зависимости от значения переменной
3. Приложение получает адрес БД из переменной окружения DATABASE_URL.

#### Решение
1. Выполнено. Приложение видит БД и стартует сразу после terraform apply
2. Выполнено с оговорками.
Попробовал передавать команду активации в виде значения переменной для count null_resource. Работает для первой копии instance в модуле, так как count null_resource занят и перебрать null_resource по всем создаваемым копиям ВМ не получается.
Ушел на менее красивое решение: count null_resource оставил под количество копий ВМ, а переменную запуском провиженера поместил в triggers null_resource.
Прошу указать на правильный путь.
3. Выполнено с оговорками.
Если про окружение в tf-модуля, то переменная останется доступной только там.
Если про окружение cli рабочего места, то не разобрался, как получить значение переменной в модуле.
Сделал проброс внутреннего ip через output из модуля db в модуль app.
Прошу указать на правильный путь.
___
___

## HW08: terraform-1

#### Задача
1. Определить input переменные для приватного ключа и зоны
2. terraform fmt
3. terraform.tfvars.example
#### Решение
done
___
#### Задача *
1.	Опишите в коде добавление ssh ключа пользователя appuser1 в метаданные проекта. 
#### Решение *
Для разнообразия добавил в метаданные инстанса, несмотря на обратную рекомендацию этого. Работает
```
metadata {
    ssh-keys = "appuser1:${replace(file(var.public_key_path),"appuser",appuser1)}
    }
```
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
___
#### Задача ***
- Создайте файл lb.tf и опишите в нем в коде terraform создание HTTP балансировщика, направляющего трафик на наше развернутое приложение на инстансе reddit-app
- Добавьте новый инстанс приложения, добавьте его в балансировщик и проверьте, что при остановке на одном из инстансов приложения (например systemctl stop puma),приложение продолжает быть доступным по адресу
- Добавьте в output переменные адрес второго инстанса
- Попробуйте подход с заданием количества инстансов через параметр ресурса count
#### Решение ***
- Создан балансировщик с использованием google_compute_target_pool
- Проверена балансировка при отключении одного из инстансов
- Новый инстанс добавлялся сразу с использованием count
#### Сложности ***
При конфигурации google_compute_instance и google_compute_target_pool хотелось бы использовать переменнную типа list, содержащую список имен инстансов.
Сложность заключается в том, что при конфигурировании ресурса google_compute_target_pool в instances[] необходимо ссылаться на count.index другого ресурса (google_compute_instance)
___
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
___

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
____

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
___

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
