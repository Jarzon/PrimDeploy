# Server installation

## Latest Apache2 on Ubuntu 16.04

https://techwombat.com/enable-http2-apache-ubuntu-16-04/

## Latest PHP version on Ubuntu 16.04

Install PHP 7.2

add-apt-repository ppa:ondrej/php
apt-get update
apt-get install -y php7.2

Make Apache use PHP 7.2 instead of 7.0 if you are'nt using FastCGI

a2dismod php
a2ensmod php7.2