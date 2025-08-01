<?php
/**
 * Delete Salamander
 * 
 * Handles deletion of salamander records
 */

// Initialize application
require_once('../../private/initialize.php');

// Include header
include(SHARED_PATH . '/salamander-header.php');

// CHANGE: Added proper spacing in control structures and improved validation
if (!isset($_GET['id'])) {
    redirect_to(url_for('salamanders/index.php'));
}
$id = $_GET['id'];

// Process deletion request
if (is_post_request()) {
    // CHANGE: Added proper spacing in control structures
    delete_salamander($id);
    redirect_to(url_for('salamanders/index.php'));
} else {
    // Get salamander data for confirmation
    $salamander = find_salamander_by_id($id);
}

// CHANGE: Changed to camelCase variable naming and added semicolon
$pageTitle = 'Delete Salamander';
?>

<!-- CHANGE: Improved HTML indentation and formatting -->
<a href="<?php echo url_for('salamanders/index.php'); ?>">&laquo; Back to Salamanders</a>

<h1>Delete Salamander</h1>
<p>Are you sure you want to delete this salamander?</p>
<p><?php echo h($salamander['name']); ?></p>

<form action="<?php echo url_for('salamanders/delete.php?id=' . h(u($salamander['id']))); ?>" method="post">
    <!-- CHANGE: Added indentation -->
    <input type="submit" name="commit" value="Delete Salamander" />
</form>

<?php include(SHARED_PATH . '/salamander-footer.php'); ?>
