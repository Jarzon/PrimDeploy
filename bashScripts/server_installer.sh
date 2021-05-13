#!/bin/bash

sudo adduser jarzon
sudo usermod -aG sudo jarzon

sudo add-apt-repository ppa:ondrej/php

sudo apt-get update
sudo apt-get upgrade
sudo apt-get -q -y install apache2 php8.0 php8.0-fpm mysql-server libapache2-mod-php git fail2ban sendmail logwatch letsencrypt
sudo apt-get -q -y install php8.0-mysql php8.0-apcu php8.0-curl php8.0-mbstring php8.0-intl php8.0-dom php8.0-imagick php8.0-gd php8.0-zip
sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

# Composer
sudo php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
php /tmp/composer-setup.php  --install-dir=/usr/bin/ --filename=composer
php -r "unlink('/tmp/composer-setup.php');"

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

sudo cat << EOF > /etc/php/8.0/fpm/conf.d/custom.ini
date.timezone = America/New_York
sendmail_path = "sendmail -t -i"
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
sudo cat << EOF > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
network: {config: disabled}
EOF
sudo cat << EOF > /etc/network/interfaces.d/failover.cfg
auto ens3:1
iface ens3:1 inet static
    address 144.217.32.66
    netmask 255.255.255.255
    broadcast 144.217.32.66
EOF
sudo cat << EOF > /etc/netplan/config.yaml
network:
     version: 2
     ethernets:
         ens3:
             dhcp4: true
             match:
                 macaddress: ${2}
             set-name: ens3
             addresses:
                 - 144.217.32.66/32
EOF

sudo a2enmod rewrite
sudo a2enmod expires
sudo a2enmod ssl
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php8.0-fpm
sudo a2enconf custom

sudo netplan apply
sudo service networking restart
sudo service ssh restart
sudo service apache2 restart
