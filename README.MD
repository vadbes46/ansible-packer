Table of Contents
- [```Ansible for CentOS```](#ansible-for-centos)
- [```Features```](#features)
- [```Installed Software```](#installed-software)
    - [```PHP 7.2.5 (remi-php72 repo) with extensions:```](#php-725-remi-php72-repo-with-extensions)
    - [```nginx 1.14.0```](#nginx-1140)
    - [```kafka 1.1.0```](#kafka-110)
    - [```Percona 5.7```](#percona-57)
    - [```composer```](#composer)
- [```Vagrant Base Box```](#vagrant-base-box)
- [```TODO```](#todo)

# ```Ansible for CentOS```

This is the template of `new ansible environment` for CentOS.

It has been grown from Ubuntu environment with all enhancements continuously appearing during 9 months.

# ```Features```
1. private VM ip is configured through .vagrantuser
2. timezone (system time) is configurable (influences on mysql, php)
3. all synced folders are defined in .vagrantuser, so never change Vagrantfile
4. check `www-data` user exists, if not - mount as `vagrant`
5. check .vagrantuser exists and not outdated, else - stop executing
6. 
7. all services are disabled by default in the box
8. ~~Box can be got from vagrant cloud as "rarek/centos7"~~

# ```Installed Software```
## ```PHP 7.2.5 (remi-php72 repo) with extensions:```
- php-bcmath
- php-cli
- php-common
- php-devel
- php-fpm
- php-gd
- php-intl
- php-json
- php-mbstring
- php-mysqlnd
- php-odbc
- php-pdo
- php-pecl-gearman
- php-pecl-memcached
- php-pecl-zip
- php-soap
- php-xml

FPM is configured to listen ports instead of sockets

## ```nginx 1.14.0```

## ```kafka 1.1.0```
kafka and zookeeper are installed as systemd services

## ```Percona 5.7```
    root / 12345678

## ```composer```

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