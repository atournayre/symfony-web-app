#!/bin/bash

## Variables
GIT_SYMFONY_DOCKER_TEMPLATE=https://github.com/dunglas/symfony-docker.git
SYMFONY_VERSION="7.2.*"
## END / Variables

# Start time
start_time=$(date +%s)

# Warnings
echo '\033[1;33mWARNING: All docker containers will be stopped. Confirm to continue.\033[00m'
read -p 'Do you want to continue? [yes/no] : ' response
if [ "$response" != 'yes' ]; then
  echo '\033[1;33mInstallation aborted.\033[00m'
  exit
fi

echo '\033[1;33m>> Stop all docker containers\033[00m'
docker kill "$(docker ps -q)"

echo '\033[1;33m>> Remove all docker containers\033[00m'
docker compose down --remove-orphans

# Section : Infrastructure
if [ -d .git ]; then
  echo '\033[1;33m>> Backup .git directory\033[00m'
	mv .git .git.bak
fi

echo '\033[1;33m>> Clone Symfony Docker template\033[00m'
rm -rf .git

echo '\033[1;33m>> Remove README.md\033[00m'
rm README.md

echo '\033[1;33m>> Initialize git repository\033[00m'
git init

echo '\033[1;33m>> Add remote origin\033[00m'
git remote add origin $GIT_SYMFONY_DOCKER_TEMPLATE

echo '\033[1;33m>> Pull latest changes\033[00m'
git pull origin main

echo '\033[1;33m>> Remove .git directory\033[00m'
rm -rf .git

if [ -d .git.bak ]; then
  echo '\033[1;33m>> Restore .git directory\033[00m'
	mv .git.bak .git
fi

echo '\033[1;33m>> Install jq\033[00m'
sed -i '/###> recipes ###/a ###> install/jq ###\nRUN apt-get update && apt-get install -y jq\n###< install/jq ###' Dockerfile

echo '\033[1;33m>> Install NPM\033[00m'
sed -i '/###> recipes ###/a ###> install/npm ###\nRUN apt-get update && apt-get install -y npm\n###< install/npm ###' Dockerfile

echo '\033[1;33m>> Install sponge\033[00m'
sed -i '/###> recipes ###/a ###> install/sponge ###\nRUN apt-get update && apt-get install -y moreutils\n###< install/sponge ###' Dockerfile

echo '\033[1;33m>> Docker build\033[00m'
docker compose build --no-cache

echo '\033[1;33m>> Fix permissions\033[00m'
docker compose run --rm php chown -R "$(id -u):$(id -g)" .

echo '\033[1;33m>> Docker up\033[00m'
docker compose up --pull always -d --wait

# Section : Dependencies
echo '\033[1;33m>> Install dependencies\033[00m'
docker exec -it "$(docker compose ps -q php)" composer require \
	api-platform/core:^3 \
	atournayre/framework:^0 \
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

echo '\033[1;33m>> Fix permissions\033[00m'
docker compose run --rm php chown -R "$(id -u):$(id -g)" .

# Section : Domain dependencies
echo '\033[1;33m>> Install domain dependencies\033[00m'
docker exec -it "$(docker compose ps -q php)" composer require \
	archtechx/enums \
	doctrine/collections \
	nesbot/carbon

echo '\033[1;33m>> Fix permissions\033[00m'
docker compose run --rm php chown -R "$(id -u):$(id -g)" .

# Section : Dev dependencies dev
echo '\033[1;33m>> Install dev dependencies\033[00m'

docker exec -it "$(docker compose ps -q php)" composer require --dev \
	zenstruck/foundry \
	zenstruck/browser \
	symfony/panther \
	symfony/var-dumper \
	symfony/web-profiler-bundle \
	thecodingmachine/phpstan-safe-rule \
	dbrekelmans/bdi

echo '\033[1;33m>> Fix permissions\033[00m'
docker compose run --rm php chown -R "$(id -u):$(id -g)" .

# Section : QA
echo '\033[1;33m>> Install QA dependencies\033[00m'
docker exec -it "$(docker compose ps -q php)" composer require --dev -W \
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
	tomasvotruba/type-coverage \
	phpstan/extension-installer

echo '\033[1;33m>> Fix permissions\033[00m'
docker compose run --rm php chown -R "$(id -u):$(id -g)" .

mkdir -p tools
mkdir -p tools/phpstan

mv _files/tools/phpstan/disallowed-calls.neon tools/phpstan/disallowed-calls.neon
mv _files/tools/phpstan/phpstan.neon tools/phpstan/phpstan.neon
mv _files/tools/rector.php tools/rector.php
mv _files/Makefile Makefile
mv _files/phpunit.xml phpunit.xml
rm phpunit.xml.dist
rm phpstan.dist.neon

# Section : Default configuration
echo '\033[1;33m>> Default configuration\033[00m'
docker exec -it "$(docker compose ps -q php)" php bin/console project:getting-started
docker exec -it "$(docker compose ps -q php)" php bin/console storybook:init
docker exec -it "$(docker compose ps -q php)" npm install
docker compose run --rm php chown -R "$(id -u):$(id -g)" .

# Section : CI/CD
echo '\033[1;33m>> CI/CD\033[00m'
rm -rf .github
mkdir -p .github
mv _files/.github/* .github/

# Section : Tests
echo '\033[1;33m>> Tests\033[00m'
mkdir -p tests
mkdir -p tests/Fixtures
mkdir -p tests/InMemory
mkdir -p tests/Test
mkdir -p tests/Test/Api
mkdir -p tests/Test/E2E
mkdir -p tests/Test/External
mkdir -p tests/Test/Functional
mkdir -p tests/Test/Integration
mkdir -p tests/Test/Performance
mkdir -p tests/Test/Unit

touch tests/Fixtures/.gitkeep
touch tests/InMemory/.gitkeep
touch tests/Test/.gitkeep
touch tests/Test/Api/.gitkeep
touch tests/Test/E2E/.gitkeep
touch tests/Test/External/.gitkeep
touch tests/Test/Functional/.gitkeep
touch tests/Test/Integration/.gitkeep
touch tests/Test/Performance/.gitkeep
touch tests/Test/Unit/.gitkeep

COMPOSER_FILE="composer.json"
docker exec -it "$(docker compose ps -q php)" bash -c "jq '.scripts[\"auto-scripts\"][\"lint:container\"] = \"symfony-cmd\"' $COMPOSER_FILE | sponge $COMPOSER_FILE"
docker exec -it "$(docker compose ps -q php)" bash -c "jq '.scripts[\"auto-scripts\"][\"lint:yaml config\"] = \"symfony-cmd\"' $COMPOSER_FILE | sponge $COMPOSER_FILE"
docker exec -it "$(docker compose ps -q php)" bash -c "jq '.scripts[\"auto-scripts\"][\"lint:container --env=prod\"] = \"symfony-cmd\"' $COMPOSER_FILE | sponge $COMPOSER_FILE"
docker exec -it "$(docker compose ps -q php)" bash -c "jq '.scripts[\"auto-scripts\"][\"lint:yaml config --env=prod\"] = \"symfony-cmd\"' $COMPOSER_FILE | sponge $COMPOSER_FILE"

docker exec -it "$(docker compose ps -q php)" bash -c "jq '.scripts[\"test\"] = \"vendor/bin/simple-phpunit\"' $COMPOSER_FILE | sponge $COMPOSER_FILE"

# Section : Documentation
echo '\033[1;33m>> Documentation\033[00m'
mkdir -p docs
touch docs/README.md

# Section : ADR
echo '\033[1;33m>> ADR\033[00m'
mkdir -p docs/adr
mv _files/docs/architecture-decision-records.md docs/architecture-decision-records.md
mv _files/docs/adr/ADR-0001-Use-Postgresql-Database.md docs/adr/ADR-0001-Use-Postgresql-Database.md

# Section : Clean up
echo '\033[1;33m>> Clean up\033[00m'
rm install.sh
rm -fr _files

echo '\033[1;33m>> Fix permissions\033[00m'
docker compose run --rm php chown -R "$(id -u):$(id -g)" .

echo '\033[1;33m>> Composer bump\033[00m'
docker exec -it "$(docker compose ps -q php)" composer bump

echo '\033[1;33m>> QA\033[00m'
make qa

# End time
end_time=$(date +%s)
execution_time=$((end_time - start_time))

# Execution time in minutes and seconds
execution_time_minutes=$((execution_time / 60))
execution_time_seconds=$((execution_time % 60))

echo '\033[1;32m>> 🎉 Installation completed.\033[00m'
echo '\033[1;32m>> 🕒 Execution time: '"$execution_time_minutes"' minutes '"$execution_time_seconds"' seconds.\033[00m'
echo '\033[1;32m>> 🚀 Happy coding!\033[00m'
echo ''
