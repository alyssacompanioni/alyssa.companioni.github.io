<?php
/**
 * Show Salamander Details
 * 
 * Displays details for a specific salamander record
 */

// Initialize application
require_once('../../private/initialize.php');

// Set page title and include header
$pageTitle = 'Salamander Details'; // CHANGE: Renamed variable to follow camelCase naming
include(SHARED_PATH . '/salamander-header.php');

// Get salamander ID with fallback to '1'
$id = $_GET['id'] ?? '1'; // PHP > 7.0
$salamander = find_salamander_by_id($id);
?>

<h1>Salamander Details</h1>

<!-- CHANGE: Added consistent spacing between elements and consistent HTML formatting -->
<p><span class="bold">ID: </span><?php echo h($salamander['id']); ?></p>
<p><span class="bold">Name: </span><?php echo h($salamander['name']); ?></p>
<p>
    <span class="bold">Habitat: </span><br>
    <?php echo h($salamander['habitat']); ?>
</p>
<p>
    <span class="bold">Description: </span><br>
    <?php echo h($salamander['description']); ?>
</p>

<!-- CHANGE: Replaced short echo tag with full PHP tag for consistency and PSR compliance -->
<p><a href="<?php echo url_for('salamanders/index.php'); ?>">&laquo; Back to Salamanders List</a></p>

<?php include(SHARED_PATH . '/salamander-footer.php'); ?>
