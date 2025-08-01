<?php

/**
 * Database Connection Functions
 *
 * This file contains functions for database connectivity,
 * including connection, disconnection, and error handling.
 */
// PSR Change: Added file documentation block (PSR-5)

require_once('db_credentials.php');

/**
 * Connect to the database
 *
 * @return mysqli The database connection object
 */
// PSR Change: Added function documentation block (PSR-5)
function db_connect()
{
    // PSR Change: Using 4-space indentation (PSR-12)
    $connection = mysqli_connect(DB_SERVER, DB_USER, DB_PASS, DB_NAME);
    confirm_db_connect();
    return $connection;
}

/**
 * Disconnect from the database
 *
 * @param mysqli $connection The database connection to close
 * @return void
 */
// PSR Change: Added function documentation block (PSR-5)
function db_disconnect($connection)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    if (isset($connection)) {
        // PSR Change: Added space after control structure keyword (PSR-12)
        mysqli_close($connection);
    }
}

// db_escape function is no longer needed with prepared statements
// PSR Change: Improved comment formatting for commented out code (PSR-12)
/**
 * Previously used to escape strings for database queries
 * No longer needed with prepared statements in place
 *
 * @deprecated Use prepared statements instead
 */
// function db_escape($connection, $string) {
//     return mysqli_real_escape_string($connection, $string);
// }

/**
 * Check and confirm database connection
 * Exits with error message if connection fails
 *
 * @return void
 */
// PSR Change: Added function documentation block (PSR-5)
function confirm_db_connect()
{
    // PSR Change: Using 4-space indentation (PSR-12)
    if (mysqli_connect_errno()) {
        // PSR Change: Added space after control structure keyword (PSR-12)
        $msg = "Database connection failed: ";
        $msg .= mysqli_connect_error();
        $msg .= " (" . mysqli_connect_errno() . ")";
        // PSR Change: Removed extra spaces (PSR-12)
        exit($msg);
    }
}

/**
 * Confirm query result set is valid
 * Exits with error message if query fails
 *
 * @param mysqli_result|bool $resultSet The query result to check
 * @param string $sql The SQL query that was executed
 * @return void
 */
// PSR Change: Added function documentation block (PSR-5)
function confirm_result_set($resultSet, $sql)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    if (!$resultSet) {
        // PSR Change: Added space after control structure keyword (PSR-12)
        exit("Database query failed. The SQL is: $sql");
    }
}
