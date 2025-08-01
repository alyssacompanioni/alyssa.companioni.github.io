<?php

function find_all_salamanders() {
  global $db;
  $sql = "SELECT * FROM salamander ";
  $sql .= "ORDER BY name ASC";
  $result = mysqli_query($db, $sql);
  confirm_result_set($result, $sql);
  return $result;
}

  function find_salamander_by_id($id) {
    global $db;
    
    // Create a prepared statement
    $sql = "SELECT * FROM salamander WHERE id = ?";
    $stmt = mysqli_prepare($db, $sql);
    
    // Bind the parameter 
    mysqli_stmt_bind_param($stmt, "s", $id);
    
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

function validate_salamander($salamander) {
  $errors = [];

  //name
  if (is_blank($salamander['name'])) {
    $errors[] = "Name cannot be blank.";
  }
  if (!has_length($salamander['name'], ['min' => 2, 'max' => 255])) {
    $errors[] = "Name must be between 2 and 255 characters.";
  }

  //habitat
  if (is_blank($salamander['habitat'])) {
    $errors[] = "Habitat cannot be blank.";
  }
  

  //description
  if (is_blank($salamander['description'])) {
    $errors[] = "Description cannot be blank.";
  }

  // //position
  // //Make sure we are working with an integer
  // $position_int = (int) $subject['position'];
  // if ($position_int <= 0) {
  //   $errors[] = "Position must be greater than zero.";
  // }
  // if ($position_int > 999) {
  //   $errors[] = "Position must be less than 999.";
  // }

  // //visible
  // //Make sure we are working with a string
  // $visible_str = (string) $subject['visible'];
  // if (!has_inclusion_of($visible_str, ["0", "1"])) {
  //   $errors[] = "Visible must be true or false.";
  // }

  return $errors;
}

function insert_salamander($salamander) {
  global $db;

  $errors = validate_salamander($salamander);
  if (!empty($errors)) {
    return $errors;
  }

  $sql = "INSERT into salamander (name, habitat, description) VALUES (?, ?, ?);";
  $stmt = mysqli_prepare($db, $sql);
  mysqli_stmt_bind_param($stmt, 'sss', $salamander['name'], $salamander['habitat'], $salamander['description']);
  $result = mysqli_stmt_execute($stmt);
  mysqli_stmt_close($stmt);

  if ($result) {
    return true;
  } else {
    //INSERT failed
    echo mysqli_error($db);
    db_disconnect($db);
    exit;
  }
}

function update_salamander($salamander) {
  global $db;

  $errors = validate_salamander($salamander);
  if (!empty($errors)) {
    return $errors;
  }

  $sql = "UPDATE salamander SET ";
  $sql .= "name= ?, ";
  $sql .= "habitat= ?, ";
  $sql .= "description= ? ";
  $sql .= "WHERE id= ? " ;
  $sql .= "LIMIT 1";

  $stmt = mysqli_prepare($db, $sql);
  mysqli_stmt_bind_param($stmt, 'ssss', $salamander['name'], $salamander['habitat'], $salamander['description'], $salamander['id']);
  $result = mysqli_stmt_execute($stmt);
  mysqli_stmt_close($stmt);

  if ($result) {
    return true;
  } else {
    //UPDATE failed
    echo mysqli_error($db);
    db_disconnect($db);
    exit;
  }
}

function delete_salamander($id) {
  global $db;

  $sql = "DELETE FROM salamander ";
  $sql .= "WHERE id = ? ";
  $sql .= "LIMIT 1";

  $stmt = mysqli_prepare($db, $sql);
  mysqli_stmt_bind_param($stmt, 's', $id);
  $result = mysqli_stmt_execute($stmt);
  mysqli_stmt_close($stmt);
  
  // $result = mysqli_query($db, $sql);
  //For DELETE statements, the result is true/false

  if ($result) {
    return true;
  } else {
    //DELETE failed
    echo mysqli_error($db);
    db_disconnect($db);
    exit;
  }
}

?>
