<?php
session_start();
?>


<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../css/styles.css">
    <title>User Options</title>
    
</head>
<body>


<div class="container">
    <h2>User Options</h2>
    <div class="button-container-vertical">
        <button onclick="window.location.href='changepassword.php'">Change Password</button>
        <button onclick="window.location.href='validateaccount.php'">Validate Account</button>
        <button onclick="window.location.href= ''"> Contacts</button>
        <button onclick="window.location.href='logout.php'">Log Out</button>
    </div>
</div>

</body>
</html>
