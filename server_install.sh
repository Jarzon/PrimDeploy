#!/bin/bash
source ./app/deploy/config.sh

ssh ubuntu@$ssh_server "bash -s" < ./bashScripts/server_installer.sh
ssh-copy-id $ssh_user@$ssh_server
ssh ubuntu@$ssh_server "sudo nano /etc/ssh/sshd_config" # Disable password connection config