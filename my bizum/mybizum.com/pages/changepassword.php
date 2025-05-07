<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../css/styles.css">
    <title>Change Password</title>
    
</head>
<body>

<div class="container">
    <h2>Change Password</h2>
    <form action="../../ws.mybizum.com/com/ws.php" method="GET"> 
        <input type="hidden" name="action" value="changepass">
        
        <div class="form-group">
            <label for="username">Username</label>
            <input type="text" id="username" name="username" required>
        </div>

        <div class="form-group">
            <label for="text">Current Password</label>
            <input type="password" id="password" name="password" required>
        </div>

        <div class="form-group">
            <label for="text">New Password</label>
            <input type="password" id="newpassword" name="newpassword" required>
        </div>

        <button type="submit" value="changepass">Verify</button>
    </form>
</div>

</body>
</html>
