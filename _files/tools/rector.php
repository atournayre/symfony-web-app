<?php

declare(strict_types=1);

use Rector\Config\RectorConfig;
use Rector\TypeDeclaration\Rector\StmtsAwareInterface\IncreaseDeclareStrictTypesRector;

return RectorConfig::configure()
    ->withPaths([
        __DIR__.'/../src',
        __DIR__.'/../tests',
    ])
    ->withPreparedSets(
        deadCode: true,
        codeQuality: true,
        codingStyle: true,
        privatization: true,
        earlyReturn: true,
    )
    ->withPhpSets()
    ->withRootFiles()
    ->withImportNames(
        importShortClasses: false,
        removeUnusedImports: true,
    )
    ->withConfiguredRule(IncreaseDeclareStrictTypesRector::class, [
        'limit' => 1,
    ])
;
