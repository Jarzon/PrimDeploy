#!/bin/bash
source ./app/deploy/config.sh

ssh-copy-id $ssh_user@$ssh_server && ssh $ssh_user@$ssh_server "bash -s" < ./bashScripts/server_installer.sh