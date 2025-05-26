<?php
session_start();
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../css/styles.css">
    <title>Iniciar sesión</title>
    <style>
        /* Reutilizamos el estilo anterior */
    </style>
</head>

<body>



<div class="container">
    <h2>Iniciar sesión</h2>
    <form action="action" method="GET" id="loginform"> 
        <input type="hidden" id="action" name="action" value="login">
        
        <div class="form-group">
            <label for="username">Usuario</label>
            <input type="text" id="username" name="username" required>
        </div>

        <div class="form-group">
            <label for="password">Contraseña</label>
            <input type="password" id="password" name="password" required>
        </div>

        <button type="submit" value="login">Entrar</button>
    </form>
</div>


<script src="../js/login.js"></script>
<script src="../com/clsAjax.js"></script>
</body>
</html>
