<?php
require_once('../../private/initialize.php');

if(is_post_request()) {
  //Handles form values sent by new.php
  $salamander = [];
  $salamander['name'] = $_POST['name'] ?? '';
  $salamander['habitat'] = $_POST['habitat'] ?? '';
  $salamander['description'] = $_POST['description'] ?? '';

  $result = insert_salamander($salamander);
  if($result === true) {
    $new_id = mysqli_insert_id($db);
    redirect_to(url_for('salamanders/show.php?id=' . $new_id));
  } else {
    $errors = $result; 
  }
} else {
  // redirect_to(url_for('salamanders/new.php'));
  //no new request(redirect), just redisplay the form wiTH error messages
}

$salamander_set = find_all_salamanders();
$salamander_count = mysqli_num_rows($salamander_set) +1;
mysqli_free_result($salamander_set);

$salamander = [];
$salamander['id'] = $subject_count;

$page_title = 'Create Salamander';
include(SHARED_PATH . '/salamander-header.php');
?>

<a class="back-link" href="<?php echo url_for('salamanders/index.php'); ?>">&laquo; Back to Salamanders</a>

<h1>Create Salamander</h1>

<?php echo display_errors($errors); ?>

<form action="<?php echo url_for('salamanders/new.php'); ?>" method="post">
  <label for="name">Name: </label><br>
  <input type="text" id="name" name="name"><br><br>

  <label for="habitat">Habitat: </label><br>
  <textarea rows="4" cols="50" id="habitat" name="habitat"></textarea><br><br>

  <label for="description">Description: </label><br>
  <textarea rows="4" cols="50" id="description" name="description"></textarea><br><br>

  <input type="submit" value="Create Salamander">
</form>

<?php
include(SHARED_PATH . '/salamander-footer.php');
?>
