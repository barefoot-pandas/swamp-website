#!/bin/sh

# Build, Spin Up ...

# Run Key Generation to init laravel app *inside* container
docker-compose exec app php artisan key:generate

# yeah you probably know how it do by now, very well
docker-compose exec app php artisan config:cache

# MySQL user (otional; current setup is insecure)
