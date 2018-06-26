#!/bin/bash

apt-get update && apt-get upgrade && apt-get -q -y install apache2 php mysql-server libapache2-mod-php php-mysql php-curl php-mbstring php-zip composer git fail2ban sendmail logwatch python-letsencrypt-apache

cat << EOF > /etc/apache2/conf-available/custom.conf
ServerTokens Prod
ServerSignature Off
EOF

cat << EOF > /etc/php/7.0/apache2/conf.d/custom.ini
date.timezone = America/New_York
sendmail_path = "sendmail -t -i"
session.gc_maxlifetime = 15552000
session.cookie_lifetime = 15552000
realpath_cache_size = 4096k
EOF

cat << EOF > /usr/share/logwatch/default.conf/custom.conf
MailTo = j@masterj.net
EOF

a2enmod rewrite
a2enmod expires
a2enmod ssl
a2enconf custom
service apache2 stop

echo "Generate ssl cert"

letsencrypt certonly --standalone -d masterj.net -d www.masterj.net -d packages.masterj.net
service apache2 start

echo "Add cron jobs"

(crontab -l ; echo "15 4 * * * /usr/bin/mysqldump -u root -p***REMOVED*** Facture | gzip > /var/www/invoice/dumps/dump.sql.gz") | sort - | uniq - | crontab -

reboot