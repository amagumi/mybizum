
<?php
$username = $_COOKIE['username'] ?? 'Invitado'; // Valor por defecto si no hay cookie
$balance = $_COOKIE['balance'] ?? 'Invitado'; // Valor por defecto si no hay cookie
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

<div> <p style="text-align: center">Welcome, <?php echo htmlspecialchars($username); ?></p>
<div class="container">
    <div class="button-container-vertical">
        <p> Balance total: <?php echo htmlspecialchars($balance); ?></p>
    </div>
    <!-- <h2>User Options</h2> -->
    <div class="button-container-vertical">
        <button onclick="window.location.href='bizum.php'">Bizum</button>
        <button onclick="window.location.href='balance.php'">Balance</button>
        <button onclick="window.location.href='useroptions.php'">Options</button>
    </div>
    
</div>


</body>
</html>




