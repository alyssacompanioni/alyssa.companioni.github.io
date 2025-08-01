<?php
// Prevent direct access
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
  header('Location: index.html');
  exit;
}

// Configuration
$to_email = 'hello@alyssacodes.dev'; // Your email address
$success_url = 'thank-you.html';
$error_url = 'index.html#contact';

// Input validation and sanitization
function clean_input($data)
{
  $data = trim($data);
  $data = stripslashes($data);
  $data = htmlspecialchars($data);
  return $data;
}

// Check if form was submitted
if ($_POST) {
  // Get and clean form data
  $name = clean_input($_POST['name'] ?? '');
  $email = clean_input($_POST['email'] ?? '');
  $subject = clean_input($_POST['subject'] ?? 'Portfolio Contact Form');
  $message = clean_input($_POST['message'] ?? '');

  // Validation
  $errors = [];

  if (empty($name)) {
    $errors[] = 'Name is required';
  }

  if (empty($email)) {
    $errors[] = 'Email is required';
  } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $errors[] = 'Invalid email format';
  }

  if (empty($message)) {
    $errors[] = 'Message is required';
  }

  // Basic spam protection
  if (isset($_POST['website']) && !empty($_POST['website'])) {
    // Honeypot field - if filled, it's likely spam
    header('Location: ' . $success_url);
    exit;
  }

  // If no errors, send email
  if (empty($errors)) {
    // Email subject
    $email_subject = "Portfolio Contact: " . $subject;

    // Email body
    $email_body = "You have received a new message from your portfolio contact form.\n\n";
    $email_body .= "Name: " . $name . "\n";
    $email_body .= "Email: " . $email . "\n";
    $email_body .= "Subject: " . $subject . "\n\n";
    $email_body .= "Message:\n" . $message . "\n\n";
    $email_body .= "---\n";
    $email_body .= "Sent from: " . $_SERVER['HTTP_HOST'] . "\n";
    $email_body .= "IP Address: " . $_SERVER['REMOTE_ADDR'] . "\n";
    $email_body .= "Date: " . date('Y-m-d H:i:s') . "\n";

    // Email headers
    $headers = "From: " . $name . " <" . $email . ">\r\n";
    $headers .= "Reply-To: " . $email . "\r\n";
    $headers .= "X-Mailer: PHP/" . phpversion() . "\r\n";
    $headers .= "MIME-Version: 1.0\r\n";
    $headers .= "Content-Type: text/plain; charset=UTF-8\r\n";

    // Send email
    if (mail($to_email, $email_subject, $email_body, $headers)) {
      // Success - redirect to thank you page
      header('Location: ' . $success_url);
      exit;
    } else {
      // Email failed to send
      $error_message = "Sorry, there was an error sending your message. Please try again or email me directly.";
    }
  } else {
    // Validation errors
    $error_message = "Please correct the following errors: " . implode(', ', $errors);
  }
}

// If we get here, there was an error
?>
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Contact Form Error - Alyssa Companioni</title>
  <link rel="stylesheet" href="css/styles.css">
</head>

<body>
  <section class="hero">
    <div class="container">
      <div class="hero-content" style="text-align: center;">
        <h1>Oops!</h1>
        <p class="tagline">Message Not Sent</p>
        <p class="description"><?php echo isset($error_message) ? htmlspecialchars($error_message) : 'An error occurred.'; ?></p>
        <div class="hero-buttons">
          <a href="index.html#contact" class="btn-primary">← Try Again</a>
          <a href="mailto:hello@alyssacodes.dev" class="btn-secondary">Email Directly</a>
        </div>
      </div>
    </div>
  </section>
</body>

</html>
