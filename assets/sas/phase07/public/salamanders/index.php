<?php
/**
 * Salamanders Index
 * 
 * Displays a list of all salamander records
 */

// Initialize application
require_once('../../private/initialize.php');

// Get all salamanders
$salamanderSet = find_all_salamanders(); // CHANGE: Changed to camelCase variable naming
$pageTitle = 'Salamanders'; // CHANGE: Changed to camelCase variable naming
include(SHARED_PATH . '/salamander-header.php');

?>
<h1>Salamanders</h1>

<!-- CHANGE: Replaced short echo tag with full PHP tag for consistency and PSR compliance -->
<a href="<?php echo url_for('salamanders/new.php'); ?>">Create Salamander</a>

<table class="list">
  <tr class="list">
    <th>ID</th>
    <th>Name</th>
    <th>Habitat</th>
    <th>Desc</th>
    <th>&nbsp;</th>
    <th>&nbsp;</th>
    <th>&nbsp;</th>
  </tr>

  <?php while ($salamander = mysqli_fetch_assoc($salamanderSet)) { ?>
    <!-- CHANGE: Improved HTML indentation and formatting -->
    <tr>
      <!-- CHANGE: Replaced short echo tags with full PHP tags -->
      <td><?php echo h($salamander['id']); ?></td>
      <td><?php echo h($salamander['name']); ?></td>
      <td><?php echo h($salamander['habitat']); ?></td>
      <td><?php echo h($salamander['description']); ?></td>
      <td><a class="action" href="<?php echo url_for('salamanders/show.php?id=' . h(u($salamander['id']))); ?>">View</a></td>
      <td><a class="action" href="<?php echo url_for('salamanders/edit.php?id=' . h(u($salamander['id']))); ?>">Edit</a></td>
      <td><a class="action" href="<?php echo url_for('salamanders/delete.php?id=' . h(u($salamander['id']))); ?>">Delete</a></td>
    </tr>
  <?php } ?>
</table>

<!-- CHANGE: Free database resources -->
<?php mysqli_free_result($salamanderSet); ?>

<!-- CHANGE: Fixed typo in "Amphibians" -->
Thanks to <a href="https://herpsofnc.org">Amphibians and Reptiles of North Carolina</a>

<?php include(SHARED_PATH . '/salamander-footer.php'); ?>
