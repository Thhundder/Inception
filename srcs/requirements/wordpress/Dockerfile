FROM debian:bullseye

# Installer PHP-FPM, extension MySQL, curl et client MariaDB
RUN apt-get update \
 && apt-get install -y php-fpm php-mysql curl mariadb-client \
 && sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/7.4/fpm/pool.d/www.conf \
 && rm -rf /var/lib/apt/lists/*

# Installer WP-CLI
RUN curl -sSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -o /usr/local/bin/wp \
 && chmod +x /usr/local/bin/wp

# Pré-télécharger WordPress
RUN curl -sSL https://wordpress.org/latest.tar.gz -o /tmp/wordpress.tar.gz \
 && mkdir -p /usr/src/wordpress \
 && tar -xzf /tmp/wordpress.tar.gz -C /usr/src/wordpress --strip-components=1 \
 && rm /tmp/wordpress.tar.gz

WORKDIR /var/www/html

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000
ENTRYPOINT ["/entrypoint.sh"]
