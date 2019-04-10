include .env

.PHONY: up down stop prune ps shell dbdump dbrestore uli cim cex

default: up

up:
	@echo "Starting up containers for for $(PROJECT_NAME)..."
	docker-compose.exe pull
	docker-compose.exe up -d --remove-orphans

down:
	@echo "Removing containers."
	docker-compose.exe down

stop:
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker-compose.exe stop

prune:
	@echo "Removing containers for $(PROJECT_NAME)..."
	@docker-compose.exe down -v

ps:
	@docker.exe ps --filter name="$(PROJECT_NAME)*"

shell:
	/mnt/c/programs/Git/git-bash.exe -c "winpty docker.exe exec -ti $(shell docker.exe ps --filter name='$(PROJECT_NAME)_php' --format '{{ .ID }}') sh"

dbdump:
	@echo "Creating Database Dump for $(PROJECT_NAME)..."
	docker-compose.exe run php drupal database:dump --file=../db/restore.sql --gz

dbrestore:
	@echo "Restoring database..."
	docker-compose.exe run php drupal database:restore --file='/var/www/html/db/restore.sql.gz'

uli:
	@echo "Getting admin login"
	docker-compose.exe run php drush user:login --uri="$(PROJECT_BASE_URL)":8000

cim:
	@echo "Importing Configuration"
	docker-compose.exe run php drupal config:import -y

cex:
	@echo "Exporting Configuration"
	docker-compose.exe run php drupal config:export -y

gm:
	@echo "Displaying Generate Module UI"
	docker-compose.exe run php drupal generate:module

install-source:
	@echo "Installing dependencies"
	docker-compose.exe run php composer install --prefer-source

install:
	@echo "Installing dependencies"
	composer install
	docker-compose.exe run php composer install

	
cr:
	@echo "Clearing Drupal Caches"
	docker-compose.exe run php drupal cache:rebuild all

logs:
	@echo "Displaying past containers logs"
	docker-compose.exe logs

logsf:
	@echo "Follow containers logs output"
	docker-compose.exe logs -f

dbclient:
	@echo "Opening DB client"
	docker-compose.exe run php drupal database:client

behat:
	@echo "Running behat tests"
	docker-compose.exe run php vendor/bin/behat

phpcs:
	@echo "Running coding standards on custom code"
	docker-compose.exe run php vendor/bin/phpcs --standard=vendor/drupal/coder/coder_sniffer/Drupal web/modules/custom --ignore=*.min.js --ignore=*.min.css

phpcbf:
	@echo "Beautifying custom code"
	docker-compose.exe run php vendor/bin/phpcbf --standard=vendor/drupal/coder/coder_sniffer/Drupal web/modules/custom --ignore=*.min.js --ignore=*.min.css
