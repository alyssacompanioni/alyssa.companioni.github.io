<?php require_once('../../private/initialize.php');

$page_title = 'Create Salamander'; 
include(SHARED_PATH . '/salamander-header.php'); 

  if(is_post_request() == true) {
    $salamanderName = $_POST['salamanderName'] ?? '';

    echo "Salamander Name: " . $salamanderName;

    ?>

    <br><br>

    <a class="edit-link" href="<?php echo url_for('/salamanders/edit.php'); ?>">Edit Salamander</a>
    <?php 
    
} else {
    redirect_to(url_for('/salamanders/new.php'));
}
?>
<?php include(SHARED_PATH . '/salamander-footer.php'); ?>
