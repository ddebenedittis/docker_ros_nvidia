COMPOSE_FILE := docker/docker-compose.yml

.PHONY: help build rebuild run setup start attach stop

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Bash script targets:"
	@echo "  build           Build the Docker image (via build.bash)"
	@echo "  rebuild         Build the Docker image without cache"
	@echo "  run             Run the container (via run.bash)"
	@echo ""
	@echo "Docker Compose targets:"
	@echo "  setup           One-time setup (generates .env, configures X11)"
	@echo "  start           Start the container in detached mode"
	@echo "  attach          Attach a shell to the running container"
	@echo "  stop            Stop and remove compose services"

build:
	./docker/build.bash

rebuild:
	./docker/build.bash -r

run:
	./docker/run.bash

setup:
	./docker/setup_compose.bash

start:
	docker compose -f $(COMPOSE_FILE) up -d

attach:
	docker compose -f $(COMPOSE_FILE) exec ros bash

stop:
	docker compose -f $(COMPOSE_FILE) down
