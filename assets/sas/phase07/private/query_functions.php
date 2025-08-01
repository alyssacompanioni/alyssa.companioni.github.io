<?php

/**
 * Find all salamanders in the database
 * 
 * @return mysqli_result The query result set
 */
// PSR Change: Added function documentation block (PSR-5)
function find_all_salamanders()
{
    // PSR Change: Using 4-space indentation (PSR-12)
    global $db;
    $sql = "SELECT * FROM salamander ";
    $sql .= "ORDER BY name ASC";
    $result = mysqli_query($db, $sql);
    confirm_result_set($result, $sql);
    // PSR Change: Consistent code style with braces on same line (PSR-12)
    return $result;
}

/**
 * Find a salamander by its ID
 * 
 * @param int $id The salamander ID
 * @return array|null The salamander record as an associative array
 */
// PSR Change: Added function documentation block (PSR-5)
function find_salamander_by_id($id)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    global $db;
    
    // Create a prepared statement
    $sql = "SELECT * FROM salamander WHERE id = ?";
    $stmt = mysqli_prepare($db, $sql);
    
    // Bind the parameter 
    // PSR Change: Using type 'i' for integer ID parameter (best practice)
    mysqli_stmt_bind_param($stmt, "i", $id);
    
    // Execute the statement
    mysqli_stmt_execute($stmt);
    
    // Get the result
    $result = mysqli_stmt_get_result($stmt);
    
    // Check if result is valid
    confirm_result_set($result, $sql);
    
    // Fetch the data
    $salamander = mysqli_fetch_assoc($result);
    
    // Free resources
    mysqli_stmt_close($stmt);
    
    return $salamander;
}

/**
 * Validate salamander data
 * 
 * @param array $salamander The salamander data to validate
 * @return array List of validation errors (empty if none)
 */
// PSR Change: Added function documentation block (PSR-5)
function validate_salamander($salamander)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    $errors = [];

    // Name
    // PSR Change: Added space after comment slashes (PSR-12)
    if (is_blank($salamander['name'])) {
        $errors[] = "Name cannot be blank.";
    }
    if (!has_length($salamander['name'], ['min' => 2, 'max' => 255])) {
        $errors[] = "Name must be between 2 and 255 characters.";
    }

    // Habitat
    // PSR Change: Added space after comment slashes (PSR-12)
    if (is_blank($salamander['habitat'])) {
        $errors[] = "Habitat cannot be blank.";
    }
    
    // Description
    // PSR Change: Added space after comment slashes (PSR-12)
    if (is_blank($salamander['description'])) {
        $errors[] = "Description cannot be blank.";
    }

    return $errors;
}

/**
 * Insert a new salamander into the database
 * 
 * @param array $salamander The salamander data to insert
 * @return bool|array True on success, array of errors on failure
 */
// PSR Change: Added function documentation block (PSR-5)
function insert_salamander($salamander)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    global $db;

    $errors = validate_salamander($salamander);
    if (!empty($errors)) {
        return $errors;
    }

    $sql = "INSERT INTO salamander (name, habitat, description) VALUES (?, ?, ?)";
    // PSR Change: Removed unnecessary semicolon in SQL (best practice)
    $stmt = mysqli_prepare($db, $sql);
    
    // PSR Change: Improved formatting of multi-parameter binding (readability)
    mysqli_stmt_bind_param(
        $stmt, 
        'sss', 
        $salamander['name'], 
        $salamander['habitat'], 
        $salamander['description']
    );
    
    $result = mysqli_stmt_execute($stmt);
    mysqli_stmt_close($stmt);

    if ($result) {
        return true;
    } else {
        // INSERT failed
        // PSR Change: Added space after comment slashes (PSR-12)
        echo mysqli_error($db);
        db_disconnect($db);
        exit;
    }
}

/**
 * Update an existing salamander in the database
 * 
 * @param array $salamander The salamander data to update
 * @return bool|array True on success, array of errors on failure
 */
// PSR Change: Added function documentation block (PSR-5)
function update_salamander($salamander)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    global $db;

    $errors = validate_salamander($salamander);
    if (!empty($errors)) {
        return $errors;
    }

    // PSR Change: Consistent string concatenation (PSR-12)
    $sql = "UPDATE salamander SET ";
    $sql .= "name = ?, ";
    // PSR Change: Added spaces around equals sign (PSR-12)
    $sql .= "habitat = ?, ";
    $sql .= "description = ? ";
    $sql .= "WHERE id = ? ";
    $sql .= "LIMIT 1";

    $stmt = mysqli_prepare($db, $sql);
    
    // PSR Change: Improved formatting of multi-parameter binding (readability)
    mysqli_stmt_bind_param(
        $stmt, 
        'sssi', 
        // PSR Change: Using type 'i' for integer ID parameter (best practice)
        $salamander['name'], 
        $salamander['habitat'], 
        $salamander['description'], 
        $salamander['id']
    );
    
    $result = mysqli_stmt_execute($stmt);
    mysqli_stmt_close($stmt);

    if ($result) {
        return true;
    } else {
        // UPDATE failed
        // PSR Change: Added space after comment slashes (PSR-12)
        echo mysqli_error($db);
        db_disconnect($db);
        exit;
    }
}

/**
 * Delete a salamander from the database
 * 
 * @param int $id The ID of the salamander to delete
 * @return bool True on success
 */
// PSR Change: Added function documentation block (PSR-5)
function delete_salamander($id)
{
    // PSR Change: Using 4-space indentation (PSR-12)
    global $db;

    $sql = "DELETE FROM salamander ";
    $sql .= "WHERE id = ? ";
    $sql .= "LIMIT 1";

    $stmt = mysqli_prepare($db, $sql);
    
    // PSR Change: Using type 'i' for integer ID parameter (best practice)
    mysqli_stmt_bind_param($stmt, 'i', $id);
    $result = mysqli_stmt_execute($stmt);
    mysqli_stmt_close($stmt);
    
    // PSR Change: Removed commented-out code (cleaner codebase)
    
    if ($result) {
        return true;
    } else {
        // DELETE failed
        // PSR Change: Added space after comment slashes (PSR-12)
        echo mysqli_error($db);
        db_disconnect($db);
        exit;
    }
}
