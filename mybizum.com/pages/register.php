<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../css/styles.css">
    <script src="../js/passwordValidator.js"></script>
    <title>Register</title>
    
    
</head>
<body>

<div class="containerregister">
    <h2>Registration Form</h2>
    <form action="action" method="GET" id="registerform">
        <input type="hidden" id="action" name="action" value="register">
        
        <div class="form-group">
            <label for="username">Username</label>
            <input type="text" id="username" name="username" required>
        </div>

        <div class="form-group">
            <label for="name">Name</label>
            <input type="text" id="name" name="name" required>
        </div>

        <div class="form-group">
            <label for="lastname">Last Name</label>
            <input type="text" id="lastname" name="lastname" required>
        </div>

        <div class="form-group">
            <label for="password">Password</label>
            <input type="password" id="password" name="password" required>
            <small id="passwordFeedback" class="feedback"></small> 
        </div>

        <div class="form-group">
            <label for="email">Email</label>
            <input type="email" id="email" name="email" required>
        </div>

        <button type="submit" value="register">Register</button>
    </form>
</div>

<script src="../js/register.js"></script>
<script src="../com/clsAjax.js"></script>
</body>
</html>
