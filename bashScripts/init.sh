#!/bin/bash
. ./htdocs/app/deploy/config.sh

#TODO: Create a user for the project
sudo chown -R www-data:www-data ./htdocs # TODO: Change the user from a project based user
sudo chmod 755 ./htdocs/
# TODO: Add perms for logs folder?
# TODO: Add chown for logs folder?

sudo formatEcho "Create databases"

sudo mysql --password=$password < ./htdocs/app/deploy/databases.sql
#TODO: Create a mysql user for the project

formatEcho "Enable project's vhost"
sudo a2ensite $name

sudo service apache2 reload