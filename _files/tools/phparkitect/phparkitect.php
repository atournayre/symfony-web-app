<?php

declare(strict_types=1);

use Arkitect\ClassSet;
use Arkitect\CLI\Config;
use Atournayre\PHPArkitect\Builder\RuleBuilder;
use Atournayre\PHPArkitect\Set\Sets;

return static function (Config $config): void {
    $classSet = ClassSet::fromDir(__DIR__.'/src');

    $rules = RuleBuilder::create()
        ->set(Sets::apiPlatformDoctrineExtension())
        ->set(Sets::apiPlatformState())
        ->set(Sets::apiPlatformUniformNaming())
        ->set(Sets::apiResource())
        ->set(Sets::apiUniformNaming())
        ->set(Sets::collection())
        ->set(Sets::contracts())
        ->set(Sets::decorator())
        ->set(Sets::doctrineListener())
        ->set(Sets::doctrineUniformNaming())
        ->set(Sets::domainEntities())
        ->set(Sets::dto())
        ->set(Sets::engine())
        ->set(Sets::enum())
        ->set(Sets::exception())
        ->set(Sets::http())
        ->set(Sets::logUniformNaming())
        ->set(Sets::symfonyCommand())
        ->set(Sets::symfonyController())
        ->set(Sets::symfonyEvent())
        ->set(Sets::symfonyForm())
        ->set(Sets::symfonySecurity())
        ->set(Sets::symfonyService())
        ->set(Sets::symfonyUniformNaming())
        ->set(Sets::vo())
        ->rules();

    $config->add($classSet, ...$rules);
};
