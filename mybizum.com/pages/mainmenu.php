<?php
session_start();
$username = $_SESSION['username'] ?? 'Invitado';
$balance = $_SESSION['balance'] ?? 'No disponible';
?>



<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../css/styles.css">
    <script src="../js/logout.js"></script>    
    <script src="../com/clsAjax.js"></script>
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
        <button onclick="window.location.href='useroptions.php'">Options</button>
        <button onclick="window.location.href='transactions.php'">History</button>
        <button onclick="logout()">Logout</button>

    </div>
    
</div>


<!-- Al final del archivo HTML, antes de </body> -->
<script>
    const balance = sessionStorage.getItem("balance");
    const balanceElement = document.getElementById("balance");
    if (balanceElement) {
        balanceElement.textContent = balance ?? "No disponible";
    }

    const loggedUser = "<?php echo htmlspecialchars($username); ?>";
</script>

</body>
</html>




