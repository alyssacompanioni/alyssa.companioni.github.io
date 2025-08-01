<?php
/**
 * Application initialization file
 * Sets up paths, includes necessary files, and initializes db connection
 */
// PSR Change: Added file description comment (PSR-5)

// Set cache control
header("Cache-Control: no-cache");

// Assign file paths to PHP constants
// __FILE__ returns the current path to this file
// dirname() returns the path to the parent directory
// PSR Change: Added spacing after comments (PSR-12)
define("PRIVATE_PATH", dirname(__FILE__));
define("PROJECT_PATH", dirname(PRIVATE_PATH));
define("PUBLIC_PATH", PROJECT_PATH . '/public');
define("SHARED_PATH", PRIVATE_PATH . '/shared');

// Assign the root URL to a PHP constant
// * Do not need to include the domain
// * Use same document root as webserver
// PSR Change: Added spacing after comments (PSR-12)
// PSR Change: Organized related comments together (readability)
$public_end = strpos($_SERVER['SCRIPT_NAME'], '/public') + 7;
$doc_root = substr($_SERVER['SCRIPT_NAME'], 0, $public_end);
define("WWW_ROOT", $doc_root);

// Include required files
// PSR Change: Added comment to explain inclusions (documentation)
require_once('functions.php');
require_once('database.php');
require_once('query_functions.php');
require_once('validation_functions.php');

// Initialize database connection and errors array
// PSR Change: Added comment to explain initializations (documentation)
$db = db_connect();
// PSR Change: Added space before and after equals sign (PSR-12)
$errors = [];
