#!/bin/bash
set -e

unset MYSQL_HOST

ROOT_PASS=$(cat /run/secrets/db_root_password)
USER_PASS=$(cat /run/secrets/db_user_password)

# Démarrage temporaire pour init
mysqld_safe --skip-networking &
pid=$!

# Attente
until mysqladmin ping -u root -p"$ROOT_PASS" --silent; do
  sleep 1
done

# Création base + utilisateur
mysql -u root -p"$ROOT_PASS" <<-EOSQL
  CREATE DATABASE IF NOT EXISTS wordpress
    DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
  CREATE USER IF NOT EXISTS 'wp_db_user'@'%'
    IDENTIFIED BY '$USER_PASS';
  GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_db_user'@'%';
  FLUSH PRIVILEGES;
EOSQL

# Remplacement du processus principal par MariaDB
mysqladmin shutdown -p"$ROOT_PASS"
exec mysqld
