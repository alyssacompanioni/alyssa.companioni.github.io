<?php

/**
 * Check if a value is blank
 *
 * Validates data presence
 * Uses trim() so empty spaces don't count
 * Uses === to avoid false positives
 * Better than empty() which considers "0" to be empty
 *
 * @param mixed $value The value to check
 * @return bool True if value is blank, false otherwise
 */
// PSR Change: Added function documentation block (PSR-5)
function is_blank($value)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    return !isset($value) || trim($value) === '';
}

/**
 * Check if a value has presence
 *
 * Validates data presence
 * Reverse of is_blank()
 *
 * @param mixed $value The value to check
 * @return bool True if value has presence, false otherwise
 */
// PSR Change: Added function documentation block (PSR-5)
function has_presence($value)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    return !is_blank($value);
}

/**
 * Check if string length is greater than specified value
 *
 * Validates string length
 * Spaces count toward length
 *
 * @param string $value The string to check
 * @param int $min The minimum length
 * @return bool True if string is longer than minimum
 */
// PSR Change: Added function documentation block (PSR-5)
function has_length_greater_than($value, $min)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    $length = strlen($value);
    return $length > $min;
}

/**
 * Check if string length is less than specified value
 *
 * Validates string length
 * Spaces count toward length
 *
 * @param string $value The string to check
 * @param int $max The maximum length
 * @return bool True if string is shorter than maximum
 */
// PSR Change: Added function documentation block (PSR-5)
function has_length_less_than($value, $max)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    $length = strlen($value);
    return $length < $max;
}

/**
 * Check if string length is exactly the specified value
 *
 * Validates string length
 * Spaces count toward length
 *
 * @param string $value The string to check
 * @param int $exact The exact length required
 * @return bool True if string is exactly the specified length
 */
// PSR Change: Added function documentation block (PSR-5)
function has_length_exactly($value, $exact)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    $length = strlen($value);
    // PSR Change: Using strict comparison === (PSR best practice)
    return $length === $exact;
}

/**
 * Check if string length meets specified conditions
 *
 * Combines functions has_length_greater_than, has_length_less_than, has_length_exactly
 * Spaces count toward length
 *
 * @param string $value The string to check
 * @param array $options Options array with keys 'min', 'max', 'exact'
 * @return bool True if string meets all specified length conditions
 */
// PSR Change: Added function documentation block (PSR-5)
// PSR Change: Fixed typo in comment param format from 'min => 3' to 'min' => 3 (PSR-5)
function has_length($value, $options)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    if (isset($options['min']) && !has_length_greater_than($value, $options['min'] - 1)) {
        return false;
    } elseif (isset($options['max']) && !has_length_less_than($value, $options['max'] + 1)) {
        return false;
    } elseif (isset($options['exact']) && !has_length_exactly($value, $options['exact'])) {
        return false;
    } else {
        return true;
    }
}

/**
 * Check if value is included in a set
 *
 * Validate inclusion in a set
 *
 * @param mixed $value The value to check
 * @param array $set The set of valid values
 * @return bool True if value is in the set
 */
// PSR Change: Added function documentation block (PSR-5)
function has_inclusion_of($value, $set)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    return in_array($value, $set);
}

/**
 * Check if value is excluded from a set
 *
 * Validate exclusion from a set
 *
 * @param mixed $value The value to check
 * @param array $set The set of invalid values
 * @return bool True if value is not in the set
 */
// PSR Change: Added function documentation block (PSR-5)
function has_exclusion_of($value, $set)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    return !in_array($value, $set);
}

/**
 * Check if string contains a required substring
 *
 * Validate inclusion of character(s)
 * strpos returns string start position or false
 * Uses !== to prevent position 0 from being considered false
 *
 * @param string $value The string to check
 * @param string $required_string The substring that must be present
 * @return bool True if required substring is found
 */
// PSR Change: Added function documentation block (PSR-5)
function has_string($value, $required_string)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    return strpos($value, $required_string) !== false;
}

/**
 * Check if a string has valid email format
 *
 * Validates correct format for email addresses
 * Format: [chars]@[chars].[2+ letters]
 *
 * @param string $value The email address to validate
 * @return bool True if email format is valid
 */
// PSR Change: Added function documentation block (PSR-5)
function has_valid_email_format($value)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    $email_regex = '/\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\Z/i';
    // PSR Change: Using strict comparison === (PSR best practice)
    return preg_match($email_regex, $value) === 1;
}
