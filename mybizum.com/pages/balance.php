<?php
session_start();
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../css/styles.css">
    <title>Balance</title>
    
</head>
<body>

<div> <p style="text-align: center"><?php echo $_SESSION['username']; ?>, here is your balance</p> 
<div class="container">
    <!-- <h2>User Options</h2> -->
    <div class="button-container-vertical">
        aqui iria el balance del usuario
    </div>
</div>

</body>
</html>
