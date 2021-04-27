#!/bin/bash
. ./htdocs/app/deploy/config.sh

sudo gunzip -c --keep /home/jarzon/dbBackup.sql.gz > /home/jarzon/dbBackup.sql
sudo mysql -u root -p$db_password $name < /home/jarzon/dbBackup.sql
sudo rm /home/jarzon/dbBackup.sql
