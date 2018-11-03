#!/bin/bash

#TODO: Create a function that connect to the ssh and exec a local file on the server

if [ ! -d "./app/deploy" ]; then
    printf "!!! Warning !!!\n\n"
    printf "app/deploy/ config folder not found"
    exit 1
fi

source ./app/deploy/config.sh

if [ $ssh_user = "root" ]; then
    formatEcho "Connecting to SSH with root!"
fi

# TODO: get the first command param to deploy to that version instead of the latest
# TODO: Be able to rollback to past version (phinx migrations)
# TODO: Add a flag to the command to create a phinx breakpoint
# TODO: Add a a command to know what version is deployed on the prod

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
if [ -f "/etc/sudoers.d/temp" ]; then
    formatEcho "Missing !tty_tickets, adding suoders config file"
    ssh -t $ssh_user@$ssh_server 'echo "Defaults !tty_tickets" | sudo tee /etc/sudoers.d/temp;'
fi

formatEcho "Auth on server: $ssh_server"
ssh -t $ssh_user@$ssh_server 'sudo -v'

formatEcho "Sending files to the prod server: $ssh_server"
rsync --compress --times --recursive --verbose --delete --perms --owner --group --copy-links --exclude-from './app/deploy/exclude.txt' -e 'ssh' '--rsync-path=sudo rsync' ./* $ssh_user@$ssh_server:$root_dir/$name/htdocs/

formatEcho "Checkout project back to latest branch: $currentBranch"
git checkout $currentBranch

formatEcho "Unstashing latest shash"
git stash pop

formatEcho "Create a backup of the database before the migration."
ssh $ssh_user@$ssh_server "cd $root_dir/$name && sudo bash -s" < ../PrimDeploy/bashScripts/backup.sh

formatEcho "Update the project."
ssh $ssh_user@$ssh_server "cd $root_dir/$name && sudo bash -s" < ../PrimDeploy/bashScripts/update.sh