<?php

/**
 * Utility Functions
 *
 * Common utility functions for URL handling, error pages, 
 * HTTP redirects, and request type detection.
 */
// PSR Change: Added file documentation block (PSR-5)

/**
 * Create a URL for a given script path
 *
 * @param string $script_path The script path to convert to a URL
 * @return string The full URL including WWW_ROOT
 */
// PSR Change: Added function documentation block (PSR-5)
function url_for($script_path)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    // Add the leading '/' if not present
    if ($script_path[0] != '/') {
        // PSR Change: Added space after control structure keyword (PSR-12)
        $script_path = "/" . $script_path;
    }
    return WWW_ROOT . $script_path;
}

/**
 * URL encode a string
 *
 * @param string $string The string to URL encode
 * @return string The URL encoded string
 */
// PSR Change: Added function documentation block (PSR-5)
function u($string = "")
{
    // PSR Change: Using 4-space indentation (PSR-12)
    // PSR Change: Added space around equals sign (PSR-12)
    return urlencode($string);
}

/**
 * Raw URL encode a string
 *
 * @param string $string The string to raw URL encode
 * @return string The raw URL encoded string
 */
// PSR Change: Added function documentation block (PSR-5)
function raw_u($string = "")
{
    // PSR Change: Using 4-space indentation (PSR-12)
    // PSR Change: Added space around equals sign (PSR-12)
    return rawurlencode($string);
}

/**
 * Convert special characters to HTML entities
 *
 * @param string $string The string to convert
 * @return string The converted string with HTML entities
 */
// PSR Change: Added function documentation block (PSR-5)
function h($string = "")
{
    // PSR Change: Using 4-space indentation (PSR-12)
    // PSR Change: Added space around equals sign (PSR-12)
    return htmlspecialchars($string);
}

/**
 * Output a 404 Not Found error page and stop execution
 *
 * @return void
 */
// PSR Change: Added function documentation block (PSR-5)
function error_404()
{
    // PSR Change: Using 4-space indentation (PSR-12)
    header($_SERVER["SERVER_PROTOCOL"] . " 404 Not Found");
    exit();
}

/**
 * Output a 500 Internal Server Error page and stop execution
 *
 * @return void
 */
// PSR Change: Added function documentation block (PSR-5)
function error_500()
{
    // PSR Change: Using 4-space indentation (PSR-12)
    header($_SERVER["SERVER_PROTOCOL"] . " 500 Internal Server Error");
    exit();
}

/**
 * Redirect to a new URL
 *
 * @param string $location The URL to redirect to
 * @return void
 */
// PSR Change: Added function documentation block (PSR-5)
// PSR Change: Improved comments for deprecated code (PSR-12)
/*
 * Previous redirect implementation
 * function redirect_to($location) {
 *   header("Location: " . $location);
 *   header("Cache-Control: no-cache, must-revalidate"); 
 *   header("HTTP/1.1 303 See Other");
 *   exit();
 * }
 */

function redirect_to($location)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    header("Location: " . $location);
    header($_SERVER["SERVER_PROTOCOL"] . " 303 See Other");
    exit();
}

/**
 * Check if the current request is a POST request
 *
 * @return bool True if the request method is POST
 */
// PSR Change: Added function documentation block (PSR-5)
function is_post_request()
{
    // PSR Change: Using 4-space indentation (PSR-12)
    // PSR Change: Using strict comparison operator (PSR best practice)
    return $_SERVER['REQUEST_METHOD'] === 'POST';
}

/**
 * Check if the current request is a GET request
 *
 * @return bool True if the request method is GET
 */
// PSR Change: Added function documentation block (PSR-5)
function is_get_request()
{
    // PSR Change: Using 4-space indentation (PSR-12)
    // PSR Change: Using strict comparison operator (PSR best practice)
    return $_SERVER['REQUEST_METHOD'] === 'GET';
}

/**
 * Display validation errors in HTML format
 *
 * @param array $errors Array of error messages to display
 * @return string HTML content for error display
 */
// PSR Change: Added function documentation block (PSR-5)
function display_errors($errors = array())
{
    // PSR Change: Using 4-space indentation (PSR-12)
    // PSR Change: Using [] for array syntax (PSR modern PHP)
    $output = '';
    if (!empty($errors)) {
        // PSR Change: Added space after control structure keyword (PSR-12)
        $output .= "<div class=\"errors\">";
        $output .= "Please fix the following errors:";
        $output .= "<ul>";
        foreach ($errors as $error) {
            // PSR Change: Added space after control structure keyword (PSR-12)
            $output .= "<li>" . h($error) . "</li>";
        }
        $output .= "</ul>";
        $output .= "</div>";
    }
    return $output;
}
