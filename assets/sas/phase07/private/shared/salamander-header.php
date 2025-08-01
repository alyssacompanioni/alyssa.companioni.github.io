<?php
/**
 * Salamander Header Template
 * 
 * Displays the site header, including title and navigation
 */
// PSR Change: Added file documentation block (PSR-5)

// Set cache control header
// PSR Change: Added comment explaining header purpose (documentation)
header("Cache-Control: no-cache");

// Set default page title if not already set
// PSR Change: Added descriptive comment (documentation)
if (!isset($page_title)) {
    // PSR Change: Using 4-space indentation (PSR-12)
    // PSR Change: Added space after control structure keyword (PSR-12)
    $page_title = 'Salamanders';
}
?>

<!doctype html>

<html lang="en">

<head>
    <?php // PSR Change: Consistent indentation in HTML (PSR-12) ?>
    <title>SAS - <?php echo h($page_title); ?></title>
    <meta charset="utf-8">
    <link rel="stylesheet" href="<?= url_for('stylesheets/salamanders.css'); ?>">
</head>

<body>
    <div id="wrapper">
        <header>
            <h1><a href="<?= url_for('/'); ?>">Southern Appalachian Salamanders (SAS)</a></h1>
        </header>
        <nav>
            <ul>
                <li><a href="<?= url_for('salamanders/'); ?>">Salamanders</a></li>
            </ul>
        </nav>
