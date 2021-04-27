#!/bin/bash

if [[ ! -d "./app/deploy" ]]; then
    printf "!!! Warning !!!\n\n"
    printf "app/deploy/ config folder not found"
    exit 1
fi

source ./app/deploy/config.sh

deployenvironement=${1:-prod}
deployfolder="htdocs"

if [[ $ssh_user = "root" ]]; then
    formatEcho "Connecting to SSH with root!"
fi

formatEcho "Auth on server: $ssh_server"

ssh -t $ssh_user@$ssh_server 'sudo -v'

formatEcho "Create a backup of the database before the migration."
ssh $ssh_user@$ssh_server "cd $root_dir/$name && sudo bash -s" < ../PrimDeploy/bashScripts/backup.sh

formatEcho "Fetch lastests database and data backups."
rsync --recursive --times --compress jarzon@libellum.ca:/var/www/libellum/dumps/ /home/jarzon/Documents/libellumDatabaseBackup/
rsync --recursive --times --compress jarzon@libellum.ca:/var/www/libellum/htdocs/data/ /home/jarzon/Documents/libellumDataBackup/
