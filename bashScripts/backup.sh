#!/bin/bash
. ./htdocs/app/deploy/config.sh

mysqldump -u root --password=$db_password $name | gzip > $root_dir/$name/dumps/dl-$(date +%Y%m%d%H).sql.gz