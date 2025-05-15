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

re: fclean build up

logs:
	$(COMPOSE) $(COMPOSE_FILE) $(ENV_FILE) logs -f
