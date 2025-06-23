#!/bin/bash
set -e

unset MYSQL_HOST

ROOT_PASS=$(cat /run/secrets/db_root_password)
USER_PASS=$(cat /run/secrets/db_user_password)

# On lance sans sudo donc il faut lui donner les perms d exec avec chown pour le volume
chown -R mysql:mysql /var/lib/mysql

# Démarrage temporaire pour init la db, le temps de la creation, en refusant toutes requetes
mysqld_safe --skip-networking --user=mysql &
pid=$!

# Attente quil soit tout bien setup
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

# Arrêt du serveur temporaire
mysqladmin shutdown -p"$ROOT_PASS"

# Lancement final en tant qu'utilisateur mysql
exec mysqld --user=mysql
