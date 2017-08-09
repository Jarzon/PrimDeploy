#!/bin/bash
source ./app/deploy/config.sh

#TODO: Create a function that connect to the ssh and exec a local file on the server

if [ ! -d "./app/deploy" ]; then
    formatEcho "!!!Warning!!!"
    formatEcho "deploy config folder not found"
    exit 1
fi

# TODO: get the first command param to deploy to that version instead of the latest

currentBranch=$(git rev-parse --abbrev-ref HEAD)

formatEcho "Stashing local changes"
git stash

latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)

formatEcho "Checkout project to latest version: $latestTag"
git checkout $latestTag

formatEcho "Sending files to the prod server: $ssh_server"
rsync --delete --compress --times --recursive --verbose --copy-links --exclude-from './app/deploy/exclude.txt' ./* $ssh_user@$ssh_server:$root_dir/$name/htdocs/

formatEcho "Checkout project back to latest branch: $currentBranch"
git checkout $currentBranch

formatEcho "Unstashing latest shash"
git stash apply

formatEcho "Create a backup of the database before the migration."
ssh $ssh_user@$ssh_server "cd $root_dir/$name && bash -s" < ../primdeploy/bashScripts/backup.sh

formatEcho "Update the project."
ssh $ssh_user@$ssh_server "cd $root_dir/$name && bash -s" < ../primdeploy/bashScripts/update.sh