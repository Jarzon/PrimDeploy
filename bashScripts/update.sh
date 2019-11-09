#!/bin/bash
cd ./htdocs
. ./app/deploy/config.sh

if [ -f "./composer.json" ]; then
    formatEcho "Install dependencies."

    composer --no-dev install -o --no-interaction
fi

if [ -f "./phinx.yml" ]; then
    formatEcho "Migrate Database"

    ./bin/phinx migrate
fi

if [ -f "./app/deploy/vhost.conf" ] || [ -f "./app/deploy/vhost-ssl.conf" ] ; then
    formatEcho "Update Apache config"

    if [ -f "./app/deploy/vhost.conf" ]; then
        cp ./app/deploy/vhost.conf /etc/apache2/sites-available/$name.conf
    fi

    if [ -f "./app/deploy/vhost-ssl.conf" ]; then
        cp ./app/deploy/vhost-ssl.conf /etc/apache2/sites-available/$name-ssl.conf
    fi

    service apache2 reload
fi

if [ -d "./app/cache/" ]; then
    formatEcho "Reset cache"

    rm -r ./app/cache/*
fi

if [ -f "./app/deploy/cron" ]; then
    formatEcho "Update cron jobs"

    cp ./app/deploy/cron /etc/cron.d/$name
    sudo service cron restart
fi

formatEcho "Update files permisions."

cd ../

#TODO: Use a different user for every project

formatEcho "Looking to renew SSL Cert"
letsencrypt renew --apache