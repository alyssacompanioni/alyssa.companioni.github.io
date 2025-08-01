<?php
  if(!isset($page_title)) { 
    $page_title = 'Southern Appalachian Salamanders'; 
  }
?>

<!doctype html>

<html lang="en">
  <head>
    <title>SAS - <?php echo h($page_title); 
    //Same as <title>SAS - <?= h((page_title));<title>     - shortcut for php tag and echo
    ?></title>

    <meta charset="utf-8">
    <link rel="stylesheet" media="all" href="<?php echo urlFor('/stylesheets/salamanders.css'); ?>" />
  </head>

  <body>
    <header>
      <h1><a href="<?= urlFor('/'); ?>">Southern Appalachian Salamanders (SAS)</a></h1>
    </header>
    <navigation>
      <ul>
      <li><a href="<?= urlFor('salamanders/'); ?>">Salamanders</a></li>
      </ul>
    </navigation>

