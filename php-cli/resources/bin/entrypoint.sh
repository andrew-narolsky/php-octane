#!/usr/bin/env bash
printenv | grep -v 'CRON_*' | grep -v 'WEBSITE_MOUNT_PATH*' | grep -v 'REGION_NAM*'  > /usr/src/app/.env
set -o allexport
source /usr/src/app/.env
set +o allexport

#Application start
sudo /usr/bin/supervisord -n -c /etc/supervisor/supervisor.conf