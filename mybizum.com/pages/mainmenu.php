<?php
session_start();
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../css/styles.css">
    <title>Main Menu</title>
    
</head>
<body>

<div> <p style="text-align: center"> Welcome, <?php echo $_SESSION['username']; ?></p> 
<div class="container">
    <!-- <h2>User Options</h2> -->
    <div class="button-container-vertical">
        <button onclick="window.location.href='bizum.php'">Bizum</button>
        <button onclick="window.location.href='balance.php'">Balance</button>
        <button onclick="window.location.href='useroptions.php'">Options</button>
    </div>
</div>

</body>
</html>
