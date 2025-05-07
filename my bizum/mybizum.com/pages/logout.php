<?php
session_start();
$sd=session_destroy();
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../css/styles.css">
    <title>Logout</title>
</head>
<body>

    <div class="container">
        <?php    
        if($sd){
            echo "<h2> Disconnected successfully </h2> ";
        }else{
            echo "<h2> Failed to disconnect </h2>";
        }
        ?>
        <button onclick="window.location.href='../start.php'">Main Menu</button>
    </div>

</body>
</html>

