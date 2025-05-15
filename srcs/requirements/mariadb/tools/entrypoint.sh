#!/bin/bash
set -e

# Pour forcer mysql client à utiliser le socket local
unset MYSQL_HOST

# Lecture des secrets
ROOT_PASS=$(cat /run/secrets/db_root_password)
USER_PASS=$(cat /run/secrets/db_user_password)

# Démarrer MariaDB temporairement en arrière-plan (skip-networking)
echo "🚀 Lancement temporaire de MariaDB pour initialisation..."
mysqld_safe --skip-networking &
pid="$!"

# Attendre que le serveur soit prêt via socket
echo "⏳ Attente du démarrage de MariaDB..."
until mysqladmin ping -u root -p"$ROOT_PASS" --silent; do
    sleep 1
done
echo "✅ MariaDB est prêt."

# Création de la base et de l’utilisateur
echo "📦 Création de la base wordpress et de l'utilisateur wp_db_user..."
mysql -u root -p"$ROOT_PASS" --protocol=socket <<EOF
CREATE DATABASE IF NOT EXISTS wordpress DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS 'wp_db_user'@'%' IDENTIFIED BY '$USER_PASS';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_db_user'@'%';
FLUSH PRIVILEGES;
EOF
echo "✅ Base et utilisateur prêts."

# Arrêter l'instance temporaire
echo "🛑 Arrêt de l'instance temporaire..."
mysqladmin shutdown -p"$ROOT_PASS"

# Lancer MariaDB en foreground (process principal)
echo "🚀 Lancement final de MariaDB..."
exec mysqld
