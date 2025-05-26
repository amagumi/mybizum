<script>
window.addEventListener('DOMContentLoaded', () => {
    const params = new URLSearchParams(window.location.search);
    const code = params.get('code');

    if (code) {
        document.getElementById("registercodehint").textContent = "Código de registro: " + code;
    }
});
</script>



<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../css/styles.css">
    <title>Verificar cuenta</title>
    
</head>
<body>

<div class="container">
    <h2>Verificar cuenta</h2>
    <form action="action" method="GET" id="validationform"> 
        <input type="hidden" id="action" name="action" value="accvalidate">
        
        <div class="form-group">
            <label for="username">Usuario</label>
            <input type="text" id="username" name="username" required>
        </div>

        <div class="form-group">
            <label for="text">Código de registro</label>
            <input type="text" id="code" name="code" required>
            <small style="color:#999999;" id="registercodehint" class="registercodehint"></small> 
        </div>

        <button type="submit" value="accvalidate">Verificar</button>
    </form>
</div>

<script src="../js/validateaccount.js"></script>
<script src="../com/clsAjax.js"></script>
</body>
</html>
