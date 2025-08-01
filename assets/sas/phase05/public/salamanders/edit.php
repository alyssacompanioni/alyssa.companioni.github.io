<?php

require_once('../../private/initialize.php');
$page_title = 'Edit Salamander';
include(SHARED_PATH . '/salamander-header.php'); 

$id = $_GET['id'];

//$salamander = find_salamander_by_id($id);
//I didn't have this line previously but it is Wallin's CH5 starter code with a note that says "should be removed but for now it works." Didn't seem to make a difference when included. 

if(is_post_request()) {
  //Handles form values sent by edit.php

  $salamander = [];
  $salamander['id'] = $id;
  $salamander['name'] = $_POST['name'] ?? '';
  $salamander['habitat'] = $_POST['habitat'] ?? '';
  $salamander['description'] = $_POST['description'] ?? '';
 
  $result = update_salamander($salamander);
  if($result === true) {
    redirect_to(url_for('salamanders/show.php?id=' . $id));
  } else {
    $errors = $result;
    //var_dump($errors);
  }
} else {
  $salamander = find_salamander_by_id($id);
}
?>

<h1>Edit Salamander</h1>

<?php echo display_errors($errors); ?>

<form action="<?php echo url_for('salamanders/edit.php?id=' . h(u($id))); ?>" method="post">
  <label for="name">Name: </label><br>
  <input type="text" id="name" name="name" value="<?php echo h($salamander['name']); ?>"><br><br>

  <label for="habitat">Habitat: </label><br>
  <textarea rows="4" cols="50" id="habitat" name="habitat"><?php echo h($salamander['habitat']); ?></textarea><br><br>

  <label for="description">Description: </label><br>
  <textarea rows="4" cols="50" id="description" name="description"><?php echo h($salamander['description']); ?></textarea><br><br>

  <input type="submit" value="Edit Salamander">
</form>

<?php
include(SHARED_PATH . '/salamander-footer.php'); ?>
