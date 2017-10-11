#!/bin/bash

apt-get update && apt-get upgrade && apt-get -q -y install apache2 php mysql-server libapache2-mod-php php-mysql php-curl php-mbstring php-zip composer git fail2ban postfix logwatch python-letsencrypt-apache