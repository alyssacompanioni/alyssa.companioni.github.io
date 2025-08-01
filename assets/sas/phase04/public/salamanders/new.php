<?php
require_once('../../private/initialize.php');

$page_title = 'Create Salamander';
include(SHARED_PATH . '/salamander-header.php');
?>

<a class="back-link" href="<?php echo url_for('salamanders/index.php'); ?>">&laquo; Back to Salamanders</a>

<h1>Create Salamander</h1>

<form action="<?php echo url_for('salamanders/create.php'); ?>" method="post">
  <label for="name">Name: </label><br>
  <input type="text" id="name" name="name" required><br><br>

  <label for="habitat">Habitat: </label><br>
  <textarea rows="4" cols="50" id="habitat" name="habitat" required></textarea><br><br>

  <label for="description">Description: </label><br>
  <textarea rows="4" cols="50" id="description" name="description" required></textarea><br><br>

  <input type="submit" value="Create Salamander">
</form>

<?php
include(SHARED_PATH . '/salamander-footer.php');
?>
