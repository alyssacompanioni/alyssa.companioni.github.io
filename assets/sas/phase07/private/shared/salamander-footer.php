<?php
/**
 * Salamander Footer Template
 * 
 * Displays the site footer and handles database disconnection
 */
// PSR Change: Added file documentation block (PSR-5)
?>

        <footer>
            &copy; <?php echo date('Y'); ?> Southern Appalachian Salamanders
        </footer>
    </div><!-- End of wrapper div -->
    <?php // PSR Change: Added comment to mark end of wrapper div (readability) ?>
</body>
</html>
  
<?php
// Disconnect from database before script ends
// PSR Change: Added descriptive comment (documentation)
db_disconnect($db);
?>
