<?php

function find_all_salamanders()
{
  global $db;
  $sql = "SELECT * FROM salamander ";
  $sql .= "ORDER BY name ASC";
  $result = mysqli_query($db, $sql);
  confirm_result_set($result, $sql);
  return $result;
}

function find_salamander_by_id($id)
{
  global $db;
  $sql = "SELECT * FROM salamander ";
  $sql .= "WHERE id='" . $id . "'";
  //It is best practice to include single quotes around the variable primary key to prevent SQL injection even though SQL doesn't require it
  $result = mysqli_query($db, $sql);
  //mysqli_query will automatically add the semicolon at the end of the query
  confirm_result_set($result, $sql);

  $salamander = mysqli_fetch_assoc($result);
  mysqli_free_result($result);

  return $salamander;
  //returns assoc array
}

function validate_salamander($salamander)
{
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

function insert_salamander($salamander)
{
  global $db;

  $errors = validate_salamander($salamander);
  if (!empty($errors)) {
    return $errors;
  }

  $sql = "INSERT into salamander ";
  $sql .= "(name, habitat, description) ";
  $sql .= "VALUES (";
  $sql .= "'" . $salamander['name'] . "', ";
  $sql .= "'" . $salamander['habitat'] . "', ";
  $sql .= "'" . $salamander['description'] . "'";
  $sql .= ");";

  $result = mysqli_query($db, $sql);
  //for INSERT statements, $result is true/false

  if ($result) {
    return true;
  } else {
    //INSERT failed
    echo mysqli_error($db);
    db_disconnect($db);
    exit;
  }
}

function update_salamander($salamander)
{
  global $db;

  $errors = validate_salamander($salamander);
  if (!empty($errors)) {
    return $errors;
  }

  $sql = "UPDATE salamander SET ";
  $sql .= "name='" . $salamander['name'] . "', ";
  $sql .= "habitat='" . $salamander['habitat'] . "', ";
  $sql .= "description='" . $salamander['description'] . "' ";
  $sql .= "WHERE id='" . $salamander['id'] . "' ";
  $sql .= "LIMIT 1";

  $result = mysqli_query($db, $sql);
  // For UPDATE statements, $result is true/false
  if ($result) {
    return true;
  } else {
    //UPDATE failed
    echo mysqli_error($db);
    db_disconnect($db);
    exit;
  }
}

function delete_salamander($id)
{
  global $db;

  $sql = "DELETE FROM salamander ";
  $sql .= "WHERE id = '" . $id . "' ";
  $sql .= "LIMIT 1";

  $result = mysqli_query($db, $sql);
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
