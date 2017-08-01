#!/bin/bash
source ./app/deploy/config.sh

if [ ! -d "./app/deploy" ]; then
    formatEcho "!!!Warning!!!"
    formatEcho "deploy config folder not found"
    exit 1
fi

formatEcho "Sending files to the prod server : $ssh_server"
rsync --delete --compress --times --recursive --verbose --copy-links --exclude-from './app/deploy/exclude.txt' ./* $ssh_user@$ssh_server:$root_dir/$name/htdocs/

formatEcho "Create a backup of the database before the migration."
ssh $ssh_user@$ssh_server "cd $root_dir/$name && bash -s" < ../primdeploy/bashScripts/backup.sh

formatEcho "Update the project."
ssh $ssh_user@$ssh_server "cd $root_dir/$name && bash -s" < ../primdeploy/bashScripts/update.sh

#TODO: Create a function that connect to the ssh and exec a local file on the server