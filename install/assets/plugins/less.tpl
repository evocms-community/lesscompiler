//<?php
/**
 * less
 * 
 * Compiling LESS styles to CSS on page init 
 *
 * @category    plugin
 * @version     1.0.0
 * @author      sergej_savelev, kassio
 * @internal    @properties &path=Path to styles;text;assets/templates/default/css/ &vars=Path to json with variables;text;
 * @internal    @events OnWebPageInit 
 * @internal    @modx_category Manager and Admin
 * @internal    @installset sample
 */

use ILess\Parser;
use ILess\FunctionRegistry;
use ILess\Node\ColorNode;
use ILess\Node\DimensionNode;

if (!empty($modx->Event) && $modx->Event->name == 'OnWebPageInit') {
    require_once MODX_BASE_PATH . 'assets/lib/ILess/Autoloader.php';
    ILess\Autoloader::register();

    $path   = trim($modx->Event->params['path'], '/') . '/';
    $styles = MODX_BASE_PATH . $path;
    $hashes = MODX_BASE_PATH . $path . '.hashes/';

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
        if ($usevars) {
            $vars = json_decode(file_get_contents(array_shift($files)), true);
        }

        foreach ($files as $basename => $filename) {
            $parser = new Parser([
                'sourceMap' => true,
                'compress'  => true,
            ]);

            if ($usevars) {
                // handle variables links
                foreach ($vars as $key => $value) {
                    $parser->parseString("@$key: $value;");
                }
            }

            $targetfile = pathinfo($basename, PATHINFO_FILENAME) . '.css';
            $mapfile    = 'assets/templates/default/css/' . $targetfile . '.map';

            $parser->getContext()->sourceMapOptions = [
                'sourceRoot' => '/',
                'filename'  => $targetfile,
                'url'       => '/' . $mapfile,
                'write_to'  => MODX_BASE_PATH . $mapfile,
                'base_path' => MODX_BASE_PATH,
            ];

            $parser->parseFile($filename);
            file_put_contents($styles . $targetfile, $parser->getCSS());
        }
    }
}
