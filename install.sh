#!/bin/bash

## Variables
GIT_SYMFONY_DOCKER_TEMPLATE=https://github.com/dunglas/symfony-docker.git
SYMFONY_VERSION="7.1.*"
## END / Variables

## Feature flag
ENABLE_WARNINGS=true
ENABLE_INFRASTRUCTURE=true
ENABLE_DEPENDENCIES=true
ENABLE_DOMAIN_DEPENDENCIES=true
ENABLE_DEV_DEPENDENCIES_DEV=true
ENABLE_QA=true
ENABLE_DEFAULT_CONFIGURATION=true
ENABLE_CI_CD=true
ENABLE_TESTS=true
ENABLE_DOCUMENTATION=true
ENABLE_ADR=true
## END / Feature flag

# Warnings
if [ $ENABLE_WARNINGS = true ]; then
	# All docker containers will be stopped : confirm to continue
	echo '\033[1;33mWARNING: All docker containers will be stopped. Confirm to continue.\033[00m'
	read -p 'Do you want to continue? [yes/no] : ' response
	if [ "$response" != 'yes' ]; then
	  echo '\033[1;33mInstallation aborted.\033[00m'
	  exit
	fi

	docker kill "$(docker ps -q)"
  docker compose down --remove-orphans
else
  echo '\033[1;33mWARNING: No checks enabled!\033[00m'
fi

# Section : Infrastructure
if [ $ENABLE_INFRASTRUCTURE = true ]; then
  echo '\033[1;33m> Infrastructure\033[00m'

  if [ -d .git ]; then
    mv .git .git.bak
  fi

  rm -rf .git

  git init
  git remote add origin $GIT_SYMFONY_DOCKER_TEMPLATE
  git pull origin main

  rm -rf .git

  if [ -d .git.bak ]; then
    mv .git.bak .git
  fi

  sed -i '/###> recipes ###/a ###> install/jq ###\nRUN apt-get update && apt-get install -y jq\n###< install/jq ###' Dockerfile
  sed -i '/###> recipes ###/a ###> install/npm ###\nRUN apt-get update && apt-get install -y npm\n###< install/npm ###' Dockerfile
  sed -i '/###> recipes ###/a ###> install/sponge ###\nRUN apt-get update && apt-get install -y moreutils\n###< install/sponge ###' Dockerfile

  docker compose build --no-cache
  docker compose run --rm php chown -R "$(id -u):$(id -g)" .

  docker exec -it "$(docker compose ps -q php)" npm --version

  docker compose down --remove-orphans

  echo "\033[1;32m>> Infrastructure completed\033[00m"
  echo ''
fi

# Section : Dependencies
if [ $ENABLE_DEPENDENCIES = true ]; then
  echo '\033[1;33m> Dependencies\033[00m'

  docker compose down --remove-orphans
  docker compose up --pull always -d --wait

  sleep 10

  docker exec -it "$(docker compose ps -q php)" composer require \
    api-platform/core:^3 \
    bgalati/monolog-sentry-handler \
    doctrine/dbal \
    doctrine/doctrine-bundle \
    doctrine/doctrine-migrations-bundle \
    doctrine/orm \
    easycorp/easyadmin-bundle \
    gedmo/doctrine-extensions \
    gotenberg/gotenberg-php \
    hautelook/alice-bundle \
    nelmio/cors-bundle \
    nikic/php-parser:~4 \
    runtime/frankenphp-symfony \
    sebastian/comparator: ^6.0 \
    sensiolabs/storybook-bundle \
    stof/doctrine-extensions-bundle \
    symfony/clock:"$SYMFONY_VERSION" \
    symfony/console:"$SYMFONY_VERSION" \
    symfony/dotenv:"$SYMFONY_VERSION" \
    symfony/expression-language:"$SYMFONY_VERSION" \
    symfony/flex:^2 \
    symfony/framework-bundle:"$SYMFONY_VERSION" \
    symfony/http-client:"$SYMFONY_VERSION" \
    symfony/mailer:"$SYMFONY_VERSION" \
    symfony/messenger:"$SYMFONY_VERSION" \
    symfony/monolog-bundle \
    symfony/notifier:"$SYMFONY_VERSION" \
    symfony/runtime:"$SYMFONY_VERSION" \
    symfony/security-bundle:"$SYMFONY_VERSION" \
    symfony/twig-bundle:"$SYMFONY_VERSION" \
    symfony/uid:"$SYMFONY_VERSION" \
    symfony/stopwatch:"$SYMFONY_VERSION" \
    symfony/validator:"$SYMFONY_VERSION" \
    symfony/yaml:"$SYMFONY_VERSION" \
    symfonycasts/reset-password-bundle \
    thecodingmachine/safe \
    twig/extra-bundle \
    twig/twig \
    webmozart/assert

  docker compose down --remove-orphans
  docker compose build
  docker compose run --rm php chown -R "$(id -u):$(id -g)" .
  docker compose down --remove-orphans

  echo '\033[1;32m>> Dependencies installed.\033[00m'
  echo ''
fi

# Section : Domain dependencies
if [ $ENABLE_DOMAIN_DEPENDENCIES = true ]; then
  echo '\033[1;33m> Domain dependencies\033[00m'

  docker compose up -d --wait

  sleep 10

  docker exec -it "$(docker compose ps -q php)" composer require \
    archtechx/enums \
    atournayre/collection \
    atournayre/null:dev-main \
    doctrine/collections \
    nesbot/carbon

  docker compose run --rm php chown -R "$(id -u):$(id -g)" .
  docker compose down --remove-orphans

  echo '\033[1;32m>> Domain dependencies completed.\033[00m'
  echo ''
fi

# Section : Dev dependencies dev
if [ $ENABLE_DEV_DEPENDENCIES_DEV = true ]; then
  echo '\033[1;33m> Dev dependencies\033[00m'

  docker compose up -d --wait

  sleep 10

  touch config/packages/atournayre_maker.yaml
  echo 'atournayre_maker:' > config/packages/atournayre_maker.yaml
  echo '  root_namespace: App' >> config/packages/atournayre_maker.yaml

  docker exec -it "$(docker compose ps -q php)" composer require --dev \
    atournayre/maker-bundle:0.0.0-beta2 \
    zenstruck/foundry \
    zenstruck/browser \
    symfony/panther \
    symfony/var-dumper \
    symfony/web-profiler-bundle \
    thecodingmachine/phpstan-safe-rule \
    dbrekelmans/bdi

  docker compose run --rm php chown -R "$(id -u):$(id -g)" .
  docker compose down --remove-orphans

  echo '\033[1;32m>> Dev dependencies completed.\033[00m'
  echo ''
fi


# Section : QA
if [ $ENABLE_QA = true ]; then
  echo '\033[1;33m> QA\033[00m'

  docker compose up -d --wait

  sleep 10

  docker exec -it "$(docker compose ps -q php)" composer require --dev -W \
  	atournayre/phparkitect-rules \
	friendsofphp/php-cs-fixer \
    rector/rector \
    rector/swiss-knife \
    phpstan/phpstan \
    phpstan/phpstan-deprecation-rules \
    phpstan/phpstan-doctrine \
    phpstan/phpstan-phpunit \
    phpstan/phpstan-symfony \
    phpstan/phpstan-strict-rules \
    phpstan/phpstan-webmozart-assert \
    symfony/phpunit-bridge \
    spaze/phpstan-disallowed-calls \
    tomasvotruba/unused-public \
    tomasvotruba/lines \
    phpstan/extension-installer

  docker compose run --rm php chown -R "$(id -u):$(id -g)" .

  mkdir -p tools
  mkdir -p tools/phparkitect
  mkdir -p tools/phpstan

  mv _files/tools/phparkitect/phparkitect.php tools/phparkitect/phparkitect.php
  mv _files/tools/phpstan/disallowed-calls.neon tools/phpstan/disallowed-calls.neon
  mv _files/tools/phpstan/phpstan.neon tools/phpstan/phpstan.neon
  mv _files/tools/rector.php tools/rector.php
  mv _files/Makefile Makefile
  mv _files/phpunit.xml phpunit.xml
  rm -rf _files
  rm phpunit.xml.dist
  rm phpstan.dist.neon

  docker compose down --remove-orphans

  echo '\033[1;32m>> QA completed.\033[00m'
  echo ''
fi


# Section : Default configuration
if [ $ENABLE_DEFAULT_CONFIGURATION = true ]; then
  echo '\033[1;33m> Default configuration\033[00m'

  docker compose up -d --wait

  sleep 10

  docker exec -it "$(docker compose ps -q php)" php bin/console project:getting-started
  docker exec -it "$(docker compose ps -q php)" php bin/console storybook:init
  docker exec -it "$(docker compose ps -q php)" npm install
  docker compose run --rm php chown -R "$(id -u):$(id -g)" .

  docker compose down --remove-orphans

  echo '\033[1;32m>> Default configuration completed.\033[00m'
  echo ''
fi


# Section : CI/CD
if [ $ENABLE_CI_CD = true ]; then
  echo '\033[1;33m> CI/CD\033[00m'

  rm -rf .github
  mkdir -p .github
  mv _files/.github/* .github/
  rm -rf _files/.github

  echo '\033[1;32m>> CI/CD completed.\033[00m'
  echo ''
fi


# Section : Tests
if [ $ENABLE_TESTS = true ]; then
  echo '\033[1;33m> Tests\033[00m'

  mkdir -p tests
  mkdir -p tests/Fixtures
  mkdir -p tests/Test
  mkdir -p tests/Test/Api
  mkdir -p tests/Test/E2E
  mkdir -p tests/Test/External
  mkdir -p tests/Test/Functional
  mkdir -p tests/Test/Integration
  mkdir -p tests/Test/Performance
  mkdir -p tests/Test/Unit

  touch tests/Fixtures/.gitkeep
  touch tests/Test/.gitkeep
  touch tests/Test/Api/.gitkeep
  touch tests/Test/E2E/.gitkeep
  touch tests/Test/External/.gitkeep
  touch tests/Test/Functional/.gitkeep
  touch tests/Test/Integration/.gitkeep
  touch tests/Test/Performance/.gitkeep
  touch tests/Test/Unit/.gitkeep

  docker compose up -d --wait

  sleep 10

  COMPOSER_FILE="composer.json"
  docker exec -it "$(docker compose ps -q php)" bash -c "jq '.scripts[\"auto-scripts\"][\"lint:container\"] = \"symfony-cmd\"' $COMPOSER_FILE | sponge $COMPOSER_FILE"
  docker exec -it "$(docker compose ps -q php)" bash -c "jq '.scripts[\"auto-scripts\"][\"lint:yaml config\"] = \"symfony-cmd\"' $COMPOSER_FILE | sponge $COMPOSER_FILE"
  docker exec -it "$(docker compose ps -q php)" bash -c "jq '.scripts[\"auto-scripts\"][\"lint:container --env=prod\"] = \"symfony-cmd\"' $COMPOSER_FILE | sponge $COMPOSER_FILE"
  docker exec -it "$(docker compose ps -q php)" bash -c "jq '.scripts[\"auto-scripts\"][\"lint:yaml config --env=prod\"] = \"symfony-cmd\"' $COMPOSER_FILE | sponge $COMPOSER_FILE"

  docker exec -it "$(docker compose ps -q php)" bash -c "jq '.scripts[\"test\"] = \"vendor/bin/simple-phpunit\"' $COMPOSER_FILE | sponge $COMPOSER_FILE"

  docker compose down --remove-orphans

  echo '\033[1;32m>> Tests completed.\033[00m'
  echo ''
fi


# Section : Documentation
if [ $ENABLE_DOCUMENTATION = true ]; then
  echo '\033[1;33m> Documentation\033[00m'

  mkdir -p docs
  touch docs/README.md

  echo '\033[1;32m>> Documentation completed.\033[00m'
  echo ''
fi


# Section : ADR
if [ $ENABLE_ADR = true ]; then
  echo '\033[1;33m> ADR\033[00m'

  mkdir -p docs/adr
  mv _files/docs/architecture-decision-records.md docs/architecture-decision-records.md
  mv _files/docs/adr/ADR-0001-Use-Postgresql-Database.md docs/adr/ADR-0001-Use-Postgresql-Database.md

  echo '# Architecture Decision Records' > docs/adr/README.md

  echo '\033[1;32m>> ADR completed.\033[00m'
  echo ''
fi


rm install.sh
rm -fr _files

docker compose up -d --wait
docker exec -it "$(docker compose ps -q php)" composer bump

make qa

echo '\033[1;32m>> 🎉 Installation completed.\033[00m'
