<?php require_once('../../private/initialize.php');

if(!isset($_GET['id'])) {
  redirect_to(url_for('/salamanders/index.php'));
}
$id = $_GET['id'];
$salamanderName = '';

if(is_post_request() == true) {
  $page_title = 'Edit Salamander'; 
  include(SHARED_PATH . '/salamander-header.php');
} else {}
?>

<div id="content">

  <a class="back-link" href="<?php echo url_for('/salamanders/index.php'); ?>">&laquo; Back to List</a>

  <div class="editSalamanderDiv">
    <h1>Edit Salamander</h1>
  
    <form action="<?php echo url_for('/salamanders/edit.php?id=' . h(u($id))); ?>" method="post">
      <label>Name<br>
        <input type="text" size="25" name="salamanderName" value="<?php echo $salamanderName;?>">
      </label><br>
      <input type="submit" value="Edit Salamander">
    </form>
  </div>

</div>

<?php include(SHARED_PATH . '/salamander-footer.php'); ?>
