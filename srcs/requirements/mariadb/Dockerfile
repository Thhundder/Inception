FROM debian:bullseye

# 1 couche unique pour installer MariaDB, configurer le bind et nettoyer le cache APT
RUN apt-get update \
 && apt-get install -y mariadb-server \
 && echo "bind-address = 0.0.0.0" >> /etc/mysql/mariadb.conf.d/50-server.cnf \
 && rm -rf /var/lib/apt/lists/*

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3306
ENTRYPOINT ["/entrypoint.sh"]
