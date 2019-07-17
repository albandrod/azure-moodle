#!/bin/bash

declare -A VERSIONS

# Controller packages
VERSIONS[apt-transport-https]=""
VERSIONS[azure-cli]=""
VERSIONS[fail2ban]=""
VERSIONS[php-common]="=1:60ubuntu1"

# Webserver packages
VERSIONS[apache2]=""
VERSIONS[gnupg]=""
VERSIONS[msodbcsql17]=""
VERSIONS[mssql-tools]=""
VERSIONS[pdo_sqlsrv]="-5.6.1" # Using PECL
VERSIONS[postgresql-client-9.6]=""
VERSIONS[sqlsrv]="-5.6.1" # Using PECL
VERSIONS[unixodbc-dev]=""

# Packages installed on both
VERSIONS[aspell]=""
VERSIONS[cifs-utils]=""
VERSIONS[git]=""
VERSIONS[glusterfs-client]=""
VERSIONS[graphviz]=""
VERSIONS[libapache2-mod-php]=""
VERSIONS[locales]=""
VERSIONS[mcrypt]="=2.6.8-1.3ubuntu2"
VERSIONS[mysql-client]="=5.7.26-0ubuntu0.18.04.1"
VERSIONS[nginx]="=1.14.0-0ubuntu1.2"
VERSIONS[php]="=1:7.2+60ubuntu1"
VERSIONS[php-bcmath]="=1:7.2+60ubuntu1"
VERSIONS[php-bz2]="=1:7.2+60ubuntu1"
VERSIONS[php-cli]="=1:7.2+60ubuntu1"
VERSIONS[php-curl]="=1:7.2+60ubuntu1"
VERSIONS[php-dev]="=1:7.2+60ubuntu1"
VERSIONS[php-fpm]="=1:7.2+60ubuntu1"
VERSIONS[php-gd]="=1:7.2+60ubuntu1"
VERSIONS[php-intl]="=1:7.2+60ubuntu1"
VERSIONS[php-json]="=1:7.2+60ubuntu1"
VERSIONS[php-mbstring]="=1:7.2+60ubuntu1"
VERSIONS[php-mysql]="=1:7.2+60ubuntu1"
VERSIONS[php-pear]="=1:1.10.5+submodules+notgz-1ubuntu1.18.04.1"
VERSIONS[php-pgsql]="=1:7.2+60ubuntu1"
VERSIONS[php-redis]="=3.1.6-1build1"
VERSIONS[php-soap]="=1:7.2+60ubuntu1"
VERSIONS[php-xml]="=1:7.2+60ubuntu1"
VERSIONS[php-xmlrpc]="=1:7.2+60ubuntu1"
VERSIONS[php-zip]="=1:7.2+60ubuntu1"
VERSIONS[postgresql-client]="=10+190"
VERSIONS[rsyslog]="=8.32.0-1ubuntu4"
VERSIONS[software-properties-common]=""
VERSIONS[unattended-upgrades]=""
VERSIONS[unzip]=""
VERSIONS[varnish]=""

# NFS
VERSIONS[autoconf]=""
VERSIONS[build-essential]=""
VERSIONS[corosync]=""
VERSIONS[crmsh]=""
VERSIONS[flex]=""
VERSIONS[nfs-kernel-server]=""
VERSIONS[pacemaker]=""
VERSIONS[resource-agents]=""
VERSIONS[systemd]=""

export VERSIONS
