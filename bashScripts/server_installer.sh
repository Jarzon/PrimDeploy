#!/bin/bash

sudo adduser jarzon
sudo usermod -aG sudo jarzon

sudo add-apt-repository ppa:ondrej/php

sudo apt-get update
sudo apt-get upgrade
sudo apt-get -q -y install apache2 php8.0 php8.0-fpm mysql-server libapache2-mod-php php8.0-mysql php8.0-apcu php8.0-curl php8.0-mbstring php8.0-intl composer git fail2ban sendmail logwatch letsencrypt chromium-browser

serverName=${1:-'newserver'}

sudo hostname ${serverName}

sudo cat << EOF > /etc/hostname
${serverName}
EOF

sudo nano /etc/hosts

sudo cat << EOF > /etc/apache2/conf-available/custom.conf
ServerTokens Prod
ServerSignature Off
Protocols h2 h2c http/1.1
<IfModule reqtimeout_module>
  RequestReadTimeout header=20-40,MinRate=500 body=20,MinRate=500
</IfModule>

EOF

sudo cat << EOF > /etc/php/7.4/fpm/conf.d/custom.ini
date.timezone = America/New_York
sendmail_path = "sendmail -t -i"
session.gc_maxlifetime = 15552000
session.cookie_lifetime = 15552000
upload_max_filesize = 8M
post_max_size = 8M

EOF

sudo cat << EOF > /usr/share/logwatch/default.conf/custom.conf
MailTo = j@jasonvaillancourt.ca

EOF

# Disable !tty_tickets to be able to reuse sudo session between to ssh access (Comes with a security risk)
sudo cat << EOF > /etc/sudoers.d/temp
Defaults !tty_tickets

EOF

# IP Failover
sudo cat << EOF > /etc/netplan/config.yaml
network:
     version: 2
     ethernets:
         ${2}:
             dhcp4: true
             match:
                 macaddress: ${3}
             set-name: ${2}
             addresses:
             - ${4}/32
EOF

sudo a2enmod rewrite
sudo a2enmod expires
sudo a2enmod ssl
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php8.0-fpm
sudo a2enconf custom

sudo netplan apply
sudo service ssh restart
sudo service apache2 restart
