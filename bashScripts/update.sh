#!/bin/bash
cd ./htdocs
. ./app/deploy/config.sh

formatEcho "Install dependencies."

composer --no-dev install -o --no-interaction

formatEcho "Update Apache config"
cp ./app/deploy/vhost.conf /etc/apache2/sites-available/$name.conf
cp ./app/deploy/vhost-ssl.conf /etc/apache2/sites-available/$name-ssl.conf
service apache2 reload

formatEcho "Migrate Database"

./bin/phinx migrate

formatEcho "Update Apache config"
cp ./app/deploy/vhost.conf /etc/apache2/sites-available/$name.conf
cp ./app/deploy/vhost-ssl.conf /etc/apache2/sites-available/$name-ssl.conf
service apache2 reload

formatEcho "Reset cache"
rm -r ./app/cache/*

formatEcho "Update files permisions."

cd ../

#TODO: Use correct permissions
#TODO: Use a different user for every project
# Have to apply it every deploy because we upload as root
chmod -R 750 ./htdocs/*
chown -R www-data:www-data ./htdocs
# TODO: Add perms for upload folder here | Create a upload folder for every project?

formatEcho "Looking to renew SSL Cert"
letsencrypt renew