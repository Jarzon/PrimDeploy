#!/bin/bash
. ./apache/htdocs/invoice/app/deploy/config.sh

rsync --compress --times $ssh_user@$ssh_server:$root_dir/$name/dumps/dl-$(date +%Y%m%d%H).sql.gz ./dumps/