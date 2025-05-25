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
    <h1>Logout</h1>
    <div class="button-container-vertical">
        <div>
            <p>Sesión cerrada con éxito. Redirigiendo...</p>
        </div>
    </div>
</div>

<script>
    setTimeout(function() {
        window.location.href = "../start.php";
    }, 2000);
</script>

</body>
</html>
