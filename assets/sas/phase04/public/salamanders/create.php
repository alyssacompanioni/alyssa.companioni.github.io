<?php

require_once('../../private/initialize.php');
include(SHARED_PATH . '/salamander-header.php'); 

if(is_post_request()) {
  //Handles form values sent by new.php
  $salamander = [];
  $salamander['name'] = $_POST['name'] ?? '';
  $salamander['habitat'] = $_POST['habitat'] ?? '';
  $salamander['description'] = $_POST['description'] ?? '';

  // echo "Form parameters: <br>";
  // echo "Salamander name: " . $name . "<br>";
  // echo "Habitat: " . $habitat . "<br>";
  // echo "Description: " . $description . "<br>";

  insert_salamander($salamander);
  $new_id = mysqli_insert_id($db);
  redirect_to(url_for('salamanders/show.php?id=' . $new_id));
} else {
  redirect_to(url_for('salamanders/new.php'));
}

include(SHARED_PATH . '/salamander-footer.php'); 
?>
