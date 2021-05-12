#!/bin/bash
. ./htdocs/app/deploy/config.sh

#TODO: Create a user for the project
sudo chown -R www-data:www-data ./htdocs
sudo chmod 755 ./htdocs/
sudo chmod -R 7770 ./htdocs/data/
sudo chmod -R 7770 ./htdocs/app/cache/
sudo chmod -R 7770 ./htdocs/public/uploads/

sudo formatEcho "Create databases"

sudo mysql --password=$password < ./htdocs/app/deploy/databases.sql

formatEcho "Enable project's vhost"
sudo a2ensite $name

sudo service apache2 reload