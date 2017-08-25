<?php

use ILess\Parser;
use ILess\FunctionRegistry;
use ILess\Node\ColorNode;
use ILess\Node\DimensionNode;

if (!empty($modx->Event) && $modx->Event->name == 'OnWebPageInit') {
    require_once MODX_BASE_PATH . 'assets/lib/ILess/Autoloader.php';
    ILess\Autoloader::register();
    
    $styles = MODX_BASE_PATH . 'assets/templates/default/css/';
    $hashes = MODX_BASE_PATH . 'assets/templates/default/css/.hashes/';
    
    if (!is_dir($hashes)) {
        mkdir($hashes, 0777, true);
    }
    
    $files = scandir(rtrim($styles, '/'));
    
    foreach ($files as $filename) {
        $fullpath = $styles . $filename;

        if (is_readable($fullpath) && (strtolower(pathinfo($fullpath, PATHINFO_EXTENSION)) == 'less')) {
            $hash   = hash('md5', file_get_contents($fullpath));
            $hashfn = $hashes . $filename . '.hash';

            if (file_exists($hashfn) && $hash == file_get_contents($hashfn)) {
                continue;
            }
            
            $parser = new Parser();
            $parser->parseFile($fullpath);

            file_put_contents($styles . substr($filename, 0, -4) . 'css', $parser->getCSS());
            file_put_contents($hashfn, $hash);
        }
    }
}