COMPOSE=docker compose
COMPOSE_FILE=-f srcs/docker-compose.yml
ENV_FILE=--env-file srcs/.env

all: build up

build:
	$(COMPOSE) $(COMPOSE_FILE) $(ENV_FILE) build

up:
	$(COMPOSE) $(COMPOSE_FILE) $(ENV_FILE) up -d

down:
	$(COMPOSE) $(COMPOSE_FILE) $(ENV_FILE) down

fclean:
	$(COMPOSE) $(COMPOSE_FILE) $(ENV_FILE) down --volumes --remove-orphans

re: reset all

logs:
	$(COMPOSE) $(COMPOSE_FILE) $(ENV_FILE) logs -f

reset: fclean
	docker builder prune -f
	docker image prune -f
	docker system prune -f --volumes
	sudo rm -rf $(HOME)/data/wordpress/* $(HOME)/data/mariadb/*
	docker compose ${COMPOSE_FILE} down --volumes --rmi all --remove-orphans
	docker network prune -f
