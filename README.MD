>**```Table Of Contents```**

- [```Ansible for CentOS```](#ansible-for-centos)
- [```Features```](#features)
    - [```.vagrantuser```](#vagrantuser)
    - [```Vagrantfile```](#vagrantfile)
    - [```Box```](#box)
- [```Installed Software```](#installed-software)
    - [```PHP 7.2.6 (remi-php72 repo)```](#php-726-remi-php72-repo)
        - [```Packages/Modules```](#packagesmodules)
        - [```Extensions```](#extensions)
        - [```Extensions compiled```](#extensions-compiled)
        - [```Configuration```](#configuration)
    - [```nginx 1.14.0```](#nginx-1140)
    - [```kafka 1.1.0```](#kafka-110)
    - [```Percona MySQL 5.7.22```](#percona-mysql-5722)
    - [```gcc 5.3.1```](#gcc-531)
    - [```composer 1.6.5```](#composer-165)
- [```Vagrant Base Box```](#vagrant-base-box)
- [```TODO```](#todo)

# ```Ansible for CentOS```

This is the template of `ansible environment` for CentOS.

It has been grown from Ubuntu environment with all enhancements continuously appearing during 9 months.

# ```Features```
## ```.vagrantuser```
1. private VM ip is configured through .vagrantuser
2. timezone (system time) is configurable (influences on mysql, php)
3. all synced folders are defined in .vagrantuser, so never change Vagrantfile
4. vault password should exist in .vagrantuser to execute private ansible rules, obtain it from IT, if empty or incorrect - skip those rules

## ```Vagrantfile```
1. check `www-data` user exists, if not - mount as `vagrant`
2. check .vagrantuser exists and not outdated, else - stop executing

## ```Box```
1. all services are disabled by default in the box
2. ~~Box can be got from vagrant cloud as "rarek/centos7"~~

# ```Installed Software```
## ```PHP 7.2.6 (remi-php72 repo)```
### ```Packages/Modules```
- php-bcmath
- php-cli
- php-common
- php-devel
- php-fpm
- php-gd
- php-mbstring
- php-mysqlnd
- php-odbc
- php-pdo
- php-process
- php-soap
- php-xml
### ```Extensions```
- php-intl
- php-json
- php-pecl-geoip
- php-pecl-memcached
- php-pecl-zip
### ```Extensions compiled```
- librdkafka v0.11.4 + php-rdkafka 3.0.5
- jaeger-client 1.1
- phalcon 3.4.0
- pinba 1.1.2-dev
- blitz 0.10.4-PHP7
- phpredis 4.0.2
- rabbitmq-c v0.9.0 + php-amqp 1.9.3
### ```Configuration```
FPM is configured to listen ports instead of sockets

## ```nginx 1.14.0```

## ```kafka 1.1.0```
    kafka and zookeeper are installed as systemd services

## ```Percona MySQL 5.7.22```
    root / 12345678

## ```gcc 5.3.1```
    installed from devtoolset-4 and configured with update-alternatives

## ```composer 1.6.5```
```fxp/composer-asset-plugin 1.4.3``` is installed as global require package

# ```Vagrant Base Box```
Commands for building image:
* `packer build -only=virtualbox-iso -force -on-error=ask box-centos.json`

After a box has been compiled it can be added with the following command
* `vagrant box add boxcentos ./packer/builds/virtualbox-packer-centos-7-x86_64.box --force`

# ```TODO```
1. ~~в боксе по дефолту не заенейблин nginx~~
2. обновить конфиги nginx (он сейчас смотрит на сокет, а фпм на порту) и сами конфиги кривоваты
3. ~~обновить конфиги фпма, чтобы смотрел на сокет~~
4. ~~убрать мусор из npm и node пакетов.~~

переехало с ансибла:
1. при vagrant up выполнить скрипт клона реп
2. при старте проверить под админом ли, проверить опции git - для винды актуально
3. плюсовые редиректы аналогично нада сделать plus01.te01-l1.nl3
4. composer clear-cache не все чистит, где то походу под рутом лежит
5. ~~сделать пятиминутный крон для чистки логов с проверкой доступности свободного места~~
   сделан двухчасовой крон чистки логов, нужно сделать чтоб по заполнению места
6. добавить таги по системам - plus, pmx, admin, terminal, и скрипты, чтобы можно было делать провижн только для нужных систем, сократив время
7. ~~чтоб сверяла даты vagrantuser и example и не делала провижн~~
8. намутить locale_gen для centos а то не проходит
9. StrictHostKeyChecking no check if needed of CentOS
10. install golang
11. запустить клон реп только если есть vault