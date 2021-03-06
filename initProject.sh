#!/bin/bash
if [[ ! -d "./app/deploy" ]]; then
    printf "!!! Warning !!!\n\n"
    printf "app/deploy/ config folder not found"
    exit 1
fi

source ./app/deploy/config.sh

formatEcho "Create server's base folders"
ssh $ssh_user@$ssh_server "cd $root_dir && sudo mkdir $name && cd $name && mkdir htdocs && mkdir logs && mkdir dumps && chown -R www-data:www-data $rootdir/$name/"

formatEcho "First deploy"
sh ../PrimDeploy/deploy.sh

formatEcho "Copy/Paste the project config"
rsync --compress --times ./app/config/config.php $ssh_user@$ssh_server:$root_dir/$name/htdocs/app/config/config.php

formatEcho "Edit the config"
ssh -t $ssh_user@$ssh_server "nano $root_dir/$name/htdocs/app/config/config.php"

formatEcho "Init the project"
ssh $sshu_ser@$ssh_server "cd $root_dir/$name && bash -s" < ../PrimDeploy/bashScripts/init.sh