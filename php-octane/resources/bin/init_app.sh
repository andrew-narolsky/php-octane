#!/usr/bin/env bash
php artisan cms:install --force --no-interaction
php artisan cache:clear
php artisan route:trans:cache
php artisan livewire:discover
