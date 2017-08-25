#!/bin/bash
. ./htdocs/app/deploy/config.sh

#TODO: Create a user for the project
chown -R www-data:www-data ./htdocs # TODO: Change the user from a project based user
chmod 755 ./htdocs/
# TODO: Add perms for logs folder?
# TODO: Add chown for logs folder?

formatEcho "Create databases"

mysql --password=$password < ./htdocs/app/deploy/databases.sql
#TODO: Create a mysql user for the project

formatEcho "Enable project's vhost"
a2ensite $name

service apache2 reload