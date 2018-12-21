#!/bin/bash

sudo apt-get update && apt-get upgrade && apt-get -q -y install apache2 php mysql-server libapache2-mod-php php-mysql php-curl php-mbstring php-zip composer git fail2ban sendmail logwatch python-letsencrypt-apache

sudo cat << EOF > /etc/apache2/conf-available/custom.conf
ServerTokens Prod
ServerSignature Off
EOF

sudo cat << EOF > /etc/php/7.0/apache2/conf.d/custom.ini
date.timezone = America/New_York
sendmail_path = "sendmail -t -i"
session.gc_maxlifetime = 15552000
session.cookie_lifetime = 15552000
realpath_cache_size = 4096k
EOF

sudo cat << EOF > /usr/share/logwatch/default.conf/custom.conf
MailTo = j@masterj.net
EOF

# Disable !tty_tickets to be able to reuse sudo session between to ssh access (Comes with so security risk)
sudo cat << EOF > /etc/sudoers.d/temp
Defaults !tty_tickets
EOF

sudo a2enmod rewrite
sudo a2enmod expires
sudo a2enmod ssl
sudo a2enconf custom
sudo service apache2 stop

echo "Generate ssl cert"

sudo letsencrypt certonly --standalone -d masterj.net -d www.masterj.net
sudo service apache2 start

sudo reboot