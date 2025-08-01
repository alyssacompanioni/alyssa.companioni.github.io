<?php
ob_start();
/**
 * Edit Salamander
 * 
 * Handles editing of existing salamander records
 */

// Initialize application
require_once('../../private/initialize.php');

// Set page title and include header
$pageTitle = 'Edit Salamander'; // CHANGE: Changed to camelCase variable naming
include(SHARED_PATH . '/salamander-header.php');

// Get salamander ID from URL
$id = $_GET['id'];

// CHANGE: Improved comment formatting for original commented-out code section
// Original code:
// $salamander = find_salamander_by_id($id);
// Note from original developer: "should be removed but for now it works."
// Didn't seem to make a difference when included.

// Process form submission
if (is_post_request()) {
    // CHANGE: Added proper spacing after control structure keywords and inside parentheses
    // Handle form values sent by edit.php
    $salamander = [];
    $salamander['id'] = $id;
    $salamander['name'] = $_POST['name'] ?? '';
    $salamander['habitat'] = $_POST['habitat'] ?? '';
    $salamander['description'] = $_POST['description'] ?? '';
    
    $result = update_salamander($salamander);
    //debugging redirect issue
    // var_dump($result);
    // exit;

    if ($result === true) {
        // CHANGE: Added proper spacing in control structures
        redirect_to(url_for('salamanders/show.php?id=' . $id));
    } else {
        $errors = $result;
        // CHANGE: Added comment for debugging line that's commented out
        //Debug line: var_dump($errors);
    }
} else {
    // Fetch salamander record if not a form submission
    $salamander = find_salamander_by_id($id);
}
?>

<h1>Edit Salamander</h1>

<?php echo display_errors($errors); ?>

<!-- CHANGE: Improved HTML indentation and formatting -->
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
include(SHARED_PATH . '/salamander-footer.php');
ob_end_flush();?>
