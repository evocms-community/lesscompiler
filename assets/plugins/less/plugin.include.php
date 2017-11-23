<?php

use ILess\Parser;
use ILess\FunctionRegistry;
use ILess\Node\ColorNode;
use ILess\Node\DimensionNode;

if (!empty($modx->Event) && $modx->Event->name == 'OnWebPageInit') {
    require_once MODX_BASE_PATH . 'assets/lib/ILess/Autoloader.php';
    ILess\Autoloader::register();

    $styles = MODX_BASE_PATH . $modx->Event->params['path'];
    $hashes = MODX_BASE_PATH . $modx->Event->params['path'] . '.hashes/';

    if (!is_dir($hashes)) {
        mkdir($hashes, 0777, true);
    }

    $files   = [];
    $update  = false;
    $usevars = false;

    $raw = glob($styles . '*.less');

    if (!empty($modx->Event->params['vars']) && is_readable(MODX_BASE_PATH . $modx->Event->params['vars'])) {
        $usevars = true;
        $update  = true;

        array_unshift($raw, MODX_BASE_PATH . $modx->Event->params['vars']);
    }

    foreach ($raw as $filename) {
        if (is_readable($filename)) {
            $basename = pathinfo($filename, PATHINFO_BASENAME);

            $hash   = hash('md5', file_get_contents($filename));
            $hashfn = $hashes . $basename . '.hash';

            if (!$update && file_exists($hashfn) && $hash == file_get_contents($hashfn)) {
                continue;
            }

            if (strpos($basename, '_') !== 0) {
                $files[$basename] = $filename;
            } else {
                $update = true;
            }

            file_put_contents($hashfn, $hash);
        }
    }

    if (!empty($files)) {
        $parser = new Parser();

        if ($usevars) {
            $vars = json_decode(file_get_contents(array_shift($files)), true);

            // handle variables links
            foreach ($vars as $key => $value) {
                if (strpos($value, '@') === 0) {
                    $value = ltrim($value, '@');

                    if (isset($vars[$value])) {
                        $vars[$key] = $vars[$value];
                    }
                }
            }

            $parser->setVariables($vars);
        }

        foreach ($files as $basename => $filename) {
            $parser->parseFile($filename);
            file_put_contents($styles . pathinfo($basename, PATHINFO_FILENAME) . '.css', $parser->getCSS());
        }
    }
}
