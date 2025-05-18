#!/bin/bash
set -e

# Préparer le socket PHP-FPM
mkdir -p /run/php
chown www-data:www-data /run/php

DB_PASS=$(cat /run/secrets/db_user_password)
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_password)
WP_USER_PASS=$(cat /run/secrets/wp_user_password)

# Attendre MariaDB
until mysqladmin ping -h"$WP_DB_HOST" -u"$WP_DB_USER" -p"$DB_PASS" --silent; do
  sleep 1
done

# Initialiser le contenu WordPress si nécessaire
if [ -z "$(ls -A /var/www/html)" ]; then
  cp -R /usr/src/wordpress/. /var/www/html
  chown -R www-data:www-data /var/www/html
fi

if [ ! -f wp-config.php ]; then
  wp core download --allow-root
  wp config create --dbname="$WP_DB_NAME" --dbuser="$WP_DB_USER" --dbpass="$DB_PASS" \
    --dbhost="$WP_DB_HOST" --dbprefix=wp_ --skip-check --allow-root
  wp core install --url="https://${DOMAIN_NAME}" --title="Inception Site" \
    --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASS" \
    --admin_email="$WP_ADMIN_EMAIL" --allow-root
  wp user create "$WP_USER" "$WP_USER_EMAIL" \
    --user_pass="$WP_USER_PASS" --role=author --allow-root
fi

# Lancer PHP-FPM au premier plan
exec php-fpm7.4 -F
