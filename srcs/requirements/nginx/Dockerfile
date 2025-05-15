FROM debian:bullseye

# Installer nginx + openssl
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Générer le certificat auto-signé au build
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh && /setup.sh

# Copier la configuration NGINX
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Répertoire partagé avec WordPress (bind mount)
WORKDIR /var/www/html

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
