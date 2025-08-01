<?php require_once('../../private/initialize.php');

$test = $_GET['test'] ?? '';
if($test == '404') {
  error_404();
} elseif($test == '500') {
  error_500();
} elseif($test == 'redirect') {
  redirect_to(url_for('/salamanders/index.php'));
} 

$page_title = 'Create Salamander'; 
include(SHARED_PATH . '/salamander-header.php');

?>

<div id="content">

  <a class="back-link" href="<?php echo url_for('/salamanders/index.php'); ?>">&laquo; Back to List</a>

  <div class="newSalamanderDiv">
    <h1>Create Salamander</h1>
  
    <form action="<?php echo url_for('/salamanders/create.php'); ?>" method="post">
      <label>Name<br>
        <input type="text" size="25" name="salamanderName">
      </label><br>
      <input type="submit" value="Create Salamander">
    </form>
  </div>

</div>

<?php include(SHARED_PATH . '/salamander-footer.php'); ?>
