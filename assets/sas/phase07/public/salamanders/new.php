<?php
/**
 * New Salamander
 * 
 * Handles creation of new salamander records
 */

// Initialize application
require_once('../../private/initialize.php');

// Process form submission
if (is_post_request()) {
    // CHANGE: Added proper spacing after control structure keywords and inside parentheses
    // CHANGE: Updated comment formatting and clarity
    // Handle form values sent by new.php
    $salamander = [];
    $salamander['name'] = $_POST['name'] ?? '';
    $salamander['habitat'] = $_POST['habitat'] ?? '';
    $salamander['description'] = $_POST['description'] ?? '';

    $result = insert_salamander($salamander);
    if ($result === true) {
        // CHANGE: Added proper spacing in control structures
        $newId = mysqli_insert_id($db); // CHANGE: Changed to camelCase variable naming
        redirect_to(url_for('salamanders/show.php?id=' . $newId));
    } else {
        $errors = $result;
    }
} else {
    // CHANGE: Improved comment formatting and made it more descriptive
    // Display the form without redirecting
    // Original commented code: redirect_to(url_for('salamanders/new.php'));
}

// Get salamander count for new ID
$salamanderSet = find_all_salamanders(); // CHANGE: Changed to camelCase variable naming
$salamanderCount = mysqli_num_rows($salamanderSet) + 1; // CHANGE: Changed to camelCase and fixed spacing
mysqli_free_result($salamanderSet);

// Initialize new salamander with ID
$salamander = [];
$salamander['id'] = $salamanderCount;

// Set page title and include header
$pageTitle = 'Create Salamander'; // CHANGE: Changed to camelCase variable naming
include(SHARED_PATH . '/salamander-header.php');
?>

<!-- CHANGE: Consistent HTML indentation and formatting -->
<a class="back-link" href="<?php echo url_for('salamanders/index.php'); ?>">&laquo; Back to Salamanders</a>

<h1>Create Salamander</h1>

<?php echo display_errors($errors); ?>

<form action="<?php echo url_for('salamanders/new.php'); ?>" method="post">
    <!-- CHANGE: Improved HTML indentation and formatting -->
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
