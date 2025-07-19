# Environment Configuration
# --------------------------------------------------
export COMPOSE_PROJECT_NAME=ternasys
export WEB_PORT_HTTP=8086
export WEB_PORT_SSL=443

# Load .env file if it exists
ifneq ("$(wildcard .env)","")
	include .env
endif

# Environment Detection
ifndef INSIDE_DOCKER_CONTAINER
	INSIDE_DOCKER_CONTAINER = 0
endif

# User and Project Configuration
HOST_UID := $(shell id -u)
HOST_GID := $(shell id -g)
PHP_USER := -u www-data
PROJECT_NAME := -p ${COMPOSE_PROJECT_NAME}
INTERACTIVE := $(shell [ -t 0 ] && echo 1)
ERROR_ONLY_FOR_HOST = @printf "\033[33mThis command is for host machine only\033[39m\n"
.DEFAULT_GOAL := help

# CI Configuration
ifneq ($(INTERACTIVE), 1)
	OPTION_T := -T
endif
ifeq ($(GITLAB_CI), 1)
	PHPUNIT_OPTIONS := --coverage-text --colors=never
endif

# Help Command
# --------------------------------------------------
help: ## Shows available commands with description
	@echo "\033[34mList of available commands:\033[39m"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

# Docker Environment Management
# --------------------------------------------------
build: ## Build dev environment
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) docker compose -f compose.yaml build --no-cache
else
	$(ERROR_ONLY_FOR_HOST)
endif

start: ## Start dev environment
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) docker compose -f compose.yaml $(PROJECT_NAME) up -d
else
	$(ERROR_ONLY_FOR_HOST)
endif

stop: ## Stop dev environment containers
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) docker compose -f compose.yaml $(PROJECT_NAME) stop
else
	$(ERROR_ONLY_FOR_HOST)
endif

down: ## Stop and remove dev environment containers, networks
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) docker compose -f compose.yaml $(PROJECT_NAME) down
else
	$(ERROR_ONLY_FOR_HOST)
endif

restart: stop start ## Stop and start dev environment

# Staging and Production Environment Management
# --------------------------------------------------
build-staging: ## Build staging environment
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) docker compose -f compose-staging.yaml build --no-cache
else
	$(ERROR_ONLY_FOR_HOST)
endif

build-prod: ## Build prod environment
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) docker compose -f compose-prod.yaml build --no-cache
else
	$(ERROR_ONLY_FOR_HOST)
endif

start-staging: ## Start staging environment
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) docker compose -f compose-staging.yaml $(PROJECT_NAME) up -d
else
	$(ERROR_ONLY_FOR_HOST)
endif

start-prod: ## Start prod environment
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) docker compose -f compose-prod.yaml $(PROJECT_NAME) up -d
else
	$(ERROR_ONLY_FOR_HOST)
endif

stop-staging: ## Stop staging environment containers
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) docker compose -f compose-staging.yaml $(PROJECT_NAME) stop
else
	$(ERROR_ONLY_FOR_HOST)
endif

stop-prod: ## Stop prod environment containers
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) docker compose -f compose-prod.yaml $(PROJECT_NAME) stop
else
	$(ERROR_ONLY_FOR_HOST)
endif

down-staging: ## Stop and remove staging environment containers, networks
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) docker compose -f compose-staging.yaml $(PROJECT_NAME) down
else
	$(ERROR_ONLY_FOR_HOST)
endif

down-prod: ## Stop and remove prod environment containers, networks
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) docker compose -f compose-prod.yaml $(PROJECT_NAME) down
else
	$(ERROR_ONLY_FOR_HOST)
endif

restart-staging: stop-staging start-staging ## Stop and start staging environment
restart-prod: stop-prod start-prod ## Stop and start prod environment

# Environment Setup
# --------------------------------------------------
env-dev: ## Creates config for dev environment
	@make exec cmd="cp ./src/.env.dev ./src/.env"

# SSH Commands
# --------------------------------------------------
ssh: ## Get bash inside app docker container
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) docker compose $(PROJECT_NAME) exec $(OPTION_T) $(PHP_USER) ${COMPOSE_PROJECT_NAME} bash
else
	$(ERROR_ONLY_FOR_HOST)
endif

ssh-root: ## Get bash as root user inside app docker container
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) docker compose $(PROJECT_NAME) exec $(OPTION_T) ${COMPOSE_PROJECT_NAME} bash
else
	$(ERROR_ONLY_FOR_HOST)
endif

ssh-nginx: ## Get bash inside nginx docker container
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) docker compose $(PROJECT_NAME) exec nginx /bin/sh
else
	$(ERROR_ONLY_FOR_HOST)
endif

# Command Execution
# --------------------------------------------------
exec:
ifeq ($(INSIDE_DOCKER_CONTAINER), 1)
	@$$cmd
else
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) docker compose $(PROJECT_NAME) exec $(OPTION_T) $(PHP_USER) ${COMPOSE_PROJECT_NAME} $$cmd
endif

exec-bash:
ifeq ($(INSIDE_DOCKER_CONTAINER), 1)
	@bash -c "$(cmd)"
else
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) docker compose $(PROJECT_NAME) exec $(OPTION_T) $(PHP_USER) ${COMPOSE_PROJECT_NAME} bash -c "$(cmd)"
endif

exec-by-root:
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) WEB_PORT_HTTP=$(WEB_PORT_HTTP) WEB_PORT_SSL=$(WEB_PORT_SSL) docker compose $(PROJECT_NAME) exec $(OPTION_T) ${COMPOSE_PROJECT_NAME} $$cmd
else
	$(ERROR_ONLY_FOR_HOST)
endif

# Application Commands
# --------------------------------------------------
artisan: ## Run artisan commands
	@make exec cmd="php artisan $(filter-out $@,$(MAKECMDGOALS))"

key-generate: ## Sets the application key
	@make exec cmd="php artisan key:generate"

migrate: ## Run database migrations
	@make exec cmd="php artisan migrate --force"

seed: ## Run database seeder
	@make exec cmd="php artisan db:seed --force"

info: ## Shows PHP and app version
	@make exec cmd="php artisan --version"
	@make exec cmd="php artisan env"
	@make exec cmd="php --version"
	@make exec cmd="composer --version"

# Logs
# --------------------------------------------------
logs: ## Shows logs from the app container. Use ctrl+c in order to exit
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@docker logs -f ${COMPOSE_PROJECT_NAME}-app
else
	$(ERROR_ONLY_FOR_HOST)
endif

logs-nginx: ## Shows logs from the nginx container. Use ctrl+c in order to exit
ifeq ($(INSIDE_DOCKER_CONTAINER), 0)
	@docker logs -f ${COMPOSE_PROJECT_NAME}-nginx
else
	$(ERROR_ONLY_FOR_HOST)
endif

# Testing and Code Coverage
# --------------------------------------------------
phpunit: ## Runs PhpUnit tests
	@make exec cmd="./vendor/bin/phpunit -c phpunit.xml --coverage-html reports/coverage $(PHPUNIT_OPTIONS) --coverage-clover reports/clover.xml --log-junit reports/junit.xml"

report-code-coverage: ## Updates code coverage on coveralls.io. Note: COVERALLS_REPO_TOKEN should be set on CI side.
	@make exec-bash cmd="export COVERALLS_REPO_TOKEN=${COVERALLS_REPO_TOKEN} && php ./vendor/bin/php-coveralls -v --coverage_clover reports/clover.xml --json_path reports/coverals.json"

# Code Analysis and Quality
# --------------------------------------------------
phpcs: ## Runs PHP CodeSniffer
	@make exec-bash cmd="./vendor/bin/phpcs --version && ./vendor/bin/phpcs --standard=PSR12 --colors -p ${COMPOSE_PROJECT_NAME} tests"

ecs: ## Runs Easy Coding Standard tool
	@make exec-bash cmd="./vendor/bin/ecs --version && ./vendor/bin/ecs --clear-cache check ${COMPOSE_PROJECT_NAME} tests"

ecs-fix: ## Runs Easy Coding Standard tool to fix issues
	@make exec-bash cmd="./vendor/bin/ecs --version && ./vendor/bin/ecs --clear-cache --fix check ${COMPOSE_PROJECT_NAME} tests"

phpmetrics: ## Generates phpmetrics static analysis report
ifeq ($(INSIDE_DOCKER_CONTAINER), 1)
	@mkdir -p reports/phpmetrics
	@if [ ! -f reports/junit.xml ] ; then \
		printf "\033[32;49mjunit.xml not found, running tests...\033[39m\n" ; \
		./vendor/bin/phpunit -c phpunit.xml --coverage-html reports/coverage --coverage-clover reports/clover.xml --log-junit reports/junit.xml ; \
	fi;
	@echo "\033[32mRunning PhpMetrics\033[39m"
	@php ./vendor/bin/phpmetrics --version
	@php ./vendor/bin/phpmetrics --junit=reports/junit.xml --report-html=reports/phpmetrics .
else
	@make exec-by-root cmd="make phpmetrics"
endif

phpcpd: ## Runs php copy/paste detector
	@make exec cmd="php phpcpd.phar --fuzzy app tests"

phpmd: ## Runs php mess detector
	@make exec cmd="php ./vendor/bin/phpmd app,tests text phpmd_ruleset.xml --suffixes php"

phpstan: ## Runs PhpStan static analysis tool
ifeq ($(INSIDE_DOCKER_CONTAINER), 1)
	@echo "\033[32mRunning PHPStan - PHP Static Analysis Tool\033[39m"
	@php artisan cache:clear --env=test
	@./vendor/bin/phpstan --version
	@./vendor/bin/phpstan analyze app tests
else
	@make exec cmd="make phpstan"
endif

phpinsights: ## Runs Php Insights analysis tool
ifeq ($(INSIDE_DOCKER_CONTAINER), 1)
	@echo "\033[32mRunning PHP Insights\033[39m"
	@php -d error_reporting=0 ./vendor/bin/phpinsights analyse --no-interaction --min-quality=100 --min-complexity=80 --min-architecture=100 --min-style=100
else
	@make exec-by-root cmd="make phpinsights"
endif

# Dependency Management
# --------------------------------------------------
composer-install-no-dev: ## Installs composer no-dev dependencies
	@make exec-bash cmd="COMPOSER_MEMORY_LIMIT=-1 composer install --optimize-autoloader --no-dev"

composer-install: ## Installs composer dependencies
	@make exec-bash cmd="COMPOSER_MEMORY_LIMIT=-1 composer install --optimize-autoloader"

composer-update: ## Updates composer dependencies
	@make exec-bash cmd="COMPOSER_MEMORY_LIMIT=-1 composer update"

composer-normalize: ## Normalizes composer.json file content
	@make exec cmd="composer normalize"

composer-validate: ## Validates composer.json file content
	@make exec cmd="composer validate --no-check-version"

composer-require-checker: ## Checks the defined dependencies against your code
	@make exec-bash cmd="XDEBUG_MODE=off php ./vendor/bin/composer-require-checker"

composer-unused: ## Shows unused packages by scanning and comparing package namespaces against your code
	@make exec-bash cmd="XDEBUG_MODE=off php ./vendor/bin/composer-unused"

# Reports
# --------------------------------------------------
report-prepare:
	@make exec cmd="mkdir -p reports/coverage"

report-clean:
	@make exec-by-root cmd="rm -rf reports/*"
