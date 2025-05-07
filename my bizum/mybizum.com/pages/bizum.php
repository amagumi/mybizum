<?php
session_start();
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../css/styles.css">
    <title>Bizum</title>
    
</head>
<body>

<div> <p style="text-align: center"> Welcome, <?php echo $_SESSION['username']; ?></p> 
<div class="container">
    <div class="button-container-vertical">
        <button onclick="window.location.href=''">enviar dinero</button>
        <button onclick="window.location.href=''">historial</button>
    </div>
</div>

</body>
</html>
