#!/bin/bash
set -e

# 1️⃣ Créer /run/php pour le PID de php-fpm
if [ ! -d /run/php ]; then
  echo "🛠️ Création du répertoire /run/php"
  mkdir -p /run/php
  chown www-data:www-data /run/php
fi

# 2️⃣ Lire les secrets
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_password)
WP_USER_PASS=$(cat /run/secrets/wp_user_password)
DB_PASS=$(cat /run/secrets/db_user_password)

# 3️⃣ Attendre MariaDB
echo "⏳ Attente de la base de données..."
until mysqladmin ping -h"$WP_DB_HOST" -u"$WP_DB_USER" -p"$DB_PASS" --silent; do
    sleep 1
done
echo "✅ Base de données disponible."

# 4️⃣ Pré-population si le volume est vide
if [ -z "$(ls -A /var/www/html)" ]; then
  echo "📋 Pré-population du volume WordPress…"
  cp -R /usr/src/wordpress/. /var/www/html
  chown -R www-data:www-data /var/www/html
fi

# 5️⃣ Installation initiale de WordPress
if [ ! -f wp-config.php ]; then
    echo "⬇️ Téléchargement de WordPress..."
    wp core download --allow-root

    echo "⚙️ Configuration de WordPress..."
    wp config create \
        --dbname="$WP_DB_NAME" \
        --dbuser="$WP_DB_USER" \
        --dbpass="$DB_PASS" \
        --dbhost="$WP_DB_HOST" \
        --dbprefix=wp_ \
        --skip-check \
        --allow-root

    echo "🔧 Installation de WordPress..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception Site" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root

    echo "👤 Création de l’utilisateur normal..."
    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASS" --role=author --allow-root
fi

# 6️⃣ Lancer PHP-FPM en foreground
echo "🚀 Lancement de PHP-FPM..."
exec php-fpm7.4 -F
