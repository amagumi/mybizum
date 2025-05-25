<?php
session_start();
$loggedUser = $_SESSION['username'] ?? null;
?>
<script>
  const loggedUser = "<?php echo htmlspecialchars($loggedUser); ?>";
</script>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="../css/styles.css" />
    <title>Historial de transacciones</title>
</head>
<body>
<div class="container">
    <h2>Historial de transacciones</h2>
    <div class="button-container-vertical">
        <div id="translist">
            <!-- Aquí se cargarán las transacciones dinámicamente -->
        </div>
    </div>
</div>

<script src="../com/clsAjax.js"></script>
<script src="../js/transactions.js"></script>
</body>
</html>
