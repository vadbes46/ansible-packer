Table of Contents
- [Ansible for CentOS](#ansible-for-centos)
- [Features](#features)
- [Installed Software](#installed-software)
    - [PHP 7.2.5 with extensions:](#php-725-with-extensions)
- [TODO](#todo)

# Ansible for CentOS

Шаблончик нового ансибла

# Features
1. private VM ip is configured through .vagrantuser
2. same for timezone, system time (influences on mysql, php)
3. .

# Installed Software
## PHP 7.2.5 with extensions:
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


# TODO

1. в боксе по дефолту не заенейблин nginx

переехало с ансибла:

2. при vagrant up выполнить скрипт клона реп
4. при старте проверить под админом ли, проверить опции git - для винды актуально
7. плюсовые редиректы аналогично нада сделать plus01.te01-l1.nl3
8. composer clear-cache не все чистит, где то походу под рутом лежит

~~9. сделать пятиминутный крон для чистки логов с проверкой доступности свободного места~~сделан двухчасовой крон чистки логов, нужно сделать чтоб по заполнению места
10. добавить таги по системам - plus, pmx, admin, terminal, и скрипты, чтобы можно было бедать провижн только для нужных систем, сократив время
11. чтоб сверяла даты vagrantuser и example и не делала провижн
12. намутить locale_gen для centos а то не проходит