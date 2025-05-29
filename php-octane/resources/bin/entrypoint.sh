#!/usr/bin/env bash
printenv > /usr/src/app/.env

set -o allexport
source /usr/src/app/.env
set +o allexport

#Application init
php artisan cms:install --force --no-interaction || true
php artisan cache:clear
php artisan route:trans:cache
php artisan livewire:discover

#Application start
php artisan octane:start --host=0.0.0.0 --port=8080
