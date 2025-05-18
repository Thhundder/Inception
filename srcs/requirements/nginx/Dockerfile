FROM debian:bullseye

RUN apt-get update \
 && apt-get install -y nginx openssl \
 && rm -rf /var/lib/apt/lists/*

COPY tools/setup.sh /setup.sh
RUN sed -i 's/\r$//' /setup.sh \
 && chmod +x /setup.sh \
 && /setup.sh

COPY conf/nginx.conf /etc/nginx/nginx.conf

WORKDIR /var/www/html

EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
