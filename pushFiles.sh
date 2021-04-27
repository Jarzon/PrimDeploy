#!/bin/bash

if [[ ! -d "./app/deploy" ]]; then
    printf "!!! Warning !!!\n\n"
    printf "app/deploy/ config folder not found"
    exit 1
fi

confirm()
{
    read -r -p "${1} [y/N] " response

    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

source ./app/deploy/config.sh

target=${1:-libellum.ca}

if [[ $ssh_user = "root" ]]; then
    formatEcho "Connecting to SSH with root!"
fi

formatEcho "Auth on server: $target"

ssh -t $ssh_user@$target 'sudo -v'

if confirm "*** ARE YOU SURE YOU WANT TO OVERWRITE $target DATABASE? ***"; then
    formatEcho "Push lastest database and data backups."
    rsync --times --compress /home/jarzon/Documents/libellumDatabaseBackup/$(date +\%Y\%m\%d-\%H\%M)* jarzon@$target:/home/jarzon/dbBackup.sql.gz
    rsync --recursive --times --compress /home/jarzon/Documents/libellumDataBackup/ jarzon@$target:/var/www/libellum/htdocs/data/

    formatEcho "Charge fresh backup back in the database"
    ssh $ssh_user@$target "cd $root_dir/$name && sudo bash -s" < ../PrimDeploy/bashScripts/load_backup.sh
else
    formatEcho "Phew!"
fi

