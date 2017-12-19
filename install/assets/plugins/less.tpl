//<?php
/**
 * less
 * 
 * Compiling LESS styles to CSS on page init 
 *
 * @category    plugin
 * @version     0.2
 * @author      sergej_savelev, kassio
 * @internal    @properties &path=Path to styles;text;assets/templates/default/css/ &vars=Path to json with variables;text;assets/templates/default/css/variables.json
 * @internal    @events OnWebPageInit 
 * @internal    @modx_category Manager and Admin
 * @internal    @installset sample
 */

require_once MODX_BASE_PATH .'/assets/plugins/less/plugin.include.php';
