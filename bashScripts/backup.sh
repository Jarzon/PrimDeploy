#!/bin/bash
. ./htdocs/app/deploy/config.sh

sudo mysqldump -u root --password=$db_password $name | gzip > $root_dir/$name/dumps/$(date +\%Y\%m\%d-\%H\%M\%S).sql.gz