<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../css/styles.css">
    <title>Validate Account</title>
    
</head>
<body>

<div class="container">
    <h2>Validate Account</h2>
    <form action="../../ws.mybizum.com/com/ws.php" method="GET"> 
        <input type="hidden" name="action" value="accvalidate">
        
        <div class="form-group">
            <label for="username">Username</label>
            <input type="text" id="username" name="username" required>
        </div>

        <div class="form-group">
            <label for="text">Register Code</label>
            <input type="text" id="code" name="code" required>
        </div>

        <button type="submit" value="accvalidate">Verify</button>
    </form>
</div>

</body>
</html>
