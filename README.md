> **Warning:** This project is a work in progress. It is not yet ready for production use.

# Symfony Web Application

By default, a [Docker](https://www.docker.com/)-based installer and runtime for the [Symfony](https://symfony.com) web framework,
with [FrankenPHP](https://frankenphp.dev) and [Caddy](https://caddyserver.com/) inside!

Based on [dunglas/symfony-docker](https://github.com/dunglas/symfony-docker)

## Getting Started

1. Edit "Variables" section in `install.sh` file
2. Run `sh install.sh`

Then read the new README.md file.

## Default Features

* Production, development and CI ready
* PHP and PostgreSQL services
* Blazing-fast performance thanks to [the worker mode of FrankenPHP](https://github.com/dunglas/frankenphp/blob/main/docs/worker.md) (automatically enabled in prod mode)
* [Installation of extra Docker Compose services](docs/extra-services.md) with Symfony Flex
* Automatic HTTPS (in dev and prod)
* HTTP/3 and [Early Hints](https://symfony.com/blog/new-in-symfony-6-3-early-hints) support
* Real-time messaging thanks to a built-in [Mercure hub](https://symfony.com/doc/current/mercure.html)
* [Vulcain](https://vulcain.rocks) support
* Native [XDebug](docs/xdebug.md) integration
* Super-readable configuration


**Enjoy!**

## What's inside?

### Infrastructure
* Symfony Docker template
* [JQ](https://stedolan.github.io/jq/) for JSON parsing
* [NPM](https://www.npmjs.com/) for JavaScript dependencies
* [PHP](https://www.php.net/) 8.3


### Dependencies
* [API Platform](https://api-platform.com) for creating modern web APIs
* [Sentry](https://sentry.io) for error tracking
* [Doctrine](https://www.doctrine-project.org/) for database management
* [EasyAdmin](https://symfony.com/doc/current/bundles/EasyAdminBundle/index.html) for admin panel
* [Doctrine extensions]()
* [Gotenberg](https://thecodingmachine.github.io/gotenberg/) for converting HTML to PDF
* [Alice Bundle]()
* [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) for cross-origin resource sharing
* [Storybook](https://storybook.js.org/) for UI components
* [Symfony](https://symfony.com) for web development
    * Clock
    * Console
    * Dotenv
    * Expression Language
    * Flex
    * Framework Bundle
    * HttpClient
    * Mailer
    * Messenger
    * Monolog
    * Notifier
    * Security
    * Twig
    * Uid
    * Stopwatch
    * Validator
    * Yaml
* [Twig](https://twig.symfony.com) for templating
* [Safe]() for safe PHP functions
* [Webmozart Assert]() for assertions

### Domain Dependencies
* [Enums]() for enumerations
* [Atournayre Collections]() for collections
* [Doctrine Collections]() for collections
* [Null]() for null objects
* [Carbon DateTime]() for date and time management

### Dev Dependencies
* [Atournayre Maker Bundle]() for generating code
* [Zenstruck Foundry]() for generating fixtures
* [Zenstruck Browser]() for testing
* [Symfony Panther]() for testing
* [Symfony Var Dumper]() for debugging
* [Symfony Web Profiler]() for debugging

### QA Dependencies
* [Atournayre PHPArkitect Ruleset]() for architecture rules
* [PHP CS Fixer]() for code style
* [Rector]() for refactoring
* [Rector Swiss Knife]() for refactoring
* [PHPStan]() for static analysis
* [PHPUnit]() for testing

### CI
* [Github Actions]() for continuous integration

### Tests
* Api for API tests
* E2E for end-to-end tests
* External for external tests
* Functional for functional tests
* Integration for integration tests
* Performance for performance tests
* Unit for unit tests

### Documentation
* README.md for the project

### Architecture Decision Records
* ADR for architecture decisions

## License

Symfony Web Application is available under the MIT License.

## Credits

Created by [Aurélien Tournayre](https://github.com/atournayre)
