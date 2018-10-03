#!/bin/bash

#TODO: Create a function that connect to the ssh and exec a local file on the server

if [ ! -d "./app/deploy" ]; then
    printf "!!! Warning !!!\n\n"
    printf "app/deploy/ config folder not found"
    exit 1
fi

source ./app/deploy/config.sh

# TODO: get the first command param to deploy to that version instead of the latest
# TODO: Be able to rollback to past version
# TODO: Add a flag to the command to create a phinx breakpoint

currentBranch=$(git rev-parse --abbrev-ref HEAD)

formatEcho "Stashing local changes"
git stash

latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)

formatEcho "Checkout project to latest version: $latestTag"
git checkout $latestTag

# Get the latest commit date
#time=$(git show -s --format=%ct HEAD)

#target = $(date -d @$time +'%Y%m%d%H%M%S')

#ssh $ssh_user@$ssh_server "cd $root_dir/$name && phinx rollback -d $target"

#TODO: use $target for phinx if you rollback and do it before you push the files on the server

formatEcho "Sending files to the prod server: $ssh_server"
rsync --delete --compress --times --recursive --verbose --copy-links --exclude-from './app/deploy/exclude.txt' ./* $ssh_user@$ssh_server:$root_dir/$name/htdocs/

formatEcho "Checkout project back to latest branch: $currentBranch"
git checkout $currentBranch

formatEcho "Unstashing latest shash"
git stash pop

formatEcho "Create a backup of the database before the migration."
ssh $ssh_user@$ssh_server "cd $root_dir/$name && bash -s" < ../primdeploy/bashScripts/backup.sh

formatEcho "Update the project."
ssh $ssh_user@$ssh_server "cd $root_dir/$name && bash -s" < ../primdeploy/bashScripts/update.sh