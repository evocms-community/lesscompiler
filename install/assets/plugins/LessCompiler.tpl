//<?php
/**
 * LessCompiler
 *
 * Compiling LESS styles to CSS on page init
 *
 * @category    plugin
 * @version     1.2.0
 * @author      sergej_savelev, kassio
 * @internal    @properties &path=Path to styles;text;theme/css/ &vars=Path to json with variables;text;theme/css/variables.json
 * @internal    @events OnWebPageInit,OnPageNotFound,OnSiteRefresh
 * @internal    @modx_category Manager and Admin
 * @internal    @installset sample
 */

require_once MODX_BASE_PATH . 'assets/plugins/lesscompiler/src/LessCompiler.php';

$compiler = new LessCompiler();

switch ($modx->event->name) {
    case 'OnWebPageInit':
    case 'OnPageNotFound': {
        return $compiler->makeCSS();
    }

    case 'OnSiteRefresh': {
        return $compiler->clearHashes();
    }
}
