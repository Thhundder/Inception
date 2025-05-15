FROM debian:bullseye

# Installer PHP-FPM, extensions, outils
RUN apt-get update && \
    apt-get install -y \
      php-fpm \
      php-mysql \
      curl \
      mariadb-client \
      unzip \
      less \
      dos2unix \
    && sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/7.4/fpm/pool.d/www.conf \
    && rm -rf /var/lib/apt/lists/*

# Installer WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Pré-télécharger WordPress dans l’image
RUN curl -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz \
 && mkdir -p /usr/src/wordpress \
 && tar -xzf /tmp/wordpress.tar.gz -C /usr/src/wordpress --strip-components=1 \
 && rm /tmp/wordpress.tar.gz

# Préparer le dossier qui sera bind-mounté
RUN mkdir -p /var/www/html

# Copier l’entrypoint et rendre exécutable
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /var/www/html

ENTRYPOINT ["/entrypoint.sh"]
