<?php

/**
 * Database Credentials Configuration
 * 
 * This file contains constants for database connection.
 * WARNING: This file should be kept secure and never committed to version control.
 */
// PSR Change: Added file documentation block (PSR-5)

// Local database connection settings
// PSR Change: Improved comment structure and organization (PSR-5)
define("DB_SERVER", "localhost");
define("DB_USER", "salamander_nerd");
define("DB_PASS", "iLoveSalamanders");
define("DB_NAME", "salamanders");

// Web host connection settings (commented out for local development)
// Uncomment these and comment out the above when deploying to production
// PSR Change: More descriptive comment about environment switching (best practice)
// define("DB_SERVER", "localhost");
// define("DB_USER", "ug1ngatwcaigr");
// define("DB_PASS", "iLoveSalamanders");
// define("DB_NAME", "dbl7zohm6xja8u");
