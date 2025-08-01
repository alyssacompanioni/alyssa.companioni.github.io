<?php

function urlFor($script_path) {
  // add the leading '/' if not already present
  if($script_path[0] != '/') {
    $script_path = "/" . $script_path;
  }
  return WWW_ROOT . $script_path;
}

function u($string="") {
  return urlencode($string);
}
/*Purpose: urlencode() is used to encode a string to be safely included in a URL by converting special characters into their percent-encoded equivalents.
Usage: It converts reserved characters (like spaces, ampersands, etc.) into a format that won't interfere with the URL's structure.
Output: Spaces are converted to + signs, and other special characters are converted to their hexadecimal representations (e.g., %20 for a space).
*/


function rawU($string="") {
  return rawurlencode($string);
}
/* Purpose: Encodes a string to be used in a URL, converting reserved characters to their percent-encoded equivalents.
Usage: Primarily used on the path part of a URL (everything before the question mark).
Example: Converts spaces to %20 and other reserved characters to their hexadecimal equivalents.
*/

function h($string="") {
  return htmlspecialchars($string);
}
/* htmlspecialchars() is a PHP function that converts special characters to HTML entities. This prevents browsers from interpreting these characters as HTML or JavaScript, which helps protect against cross-site scripting (XSS) attacks. For example, it converts < to < and > to >, making sure any dynamic data displayed on your webpage is safe. Use it whenever you output data that might contain HTML special characters.
*/

/*Compare/Contrast urlencode()/rawurlencode():
  Purpose:
    urlencode(): Encodes a string to be used in a query part of a URL.
    rawurlencode(): Encodes a string to be used in the path part of a URL.
  Encoding Spaces:
    urlencode(): Converts spaces to +.
    rawurlencode(): Converts spaces to %20.
  Usage:
    urlencode(): Best used for encoding query parameters (everything after the ? in a URL).
    rawurlencode(): Best used for encoding the path segment of a URL (everything before the ?). 
  Example:
    urlencode("Hello World!") results in Hello+World%21.
    rawurlencode("Hello World!") results in Hello%20World%21.
*/

?>
