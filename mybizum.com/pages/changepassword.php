<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="../css/styles.css" />
    <script src="../js/passwordValidator.js"></script>
    <title>Change Password</title>
</head>
<body>

<div class="container">
    <h2>Change Password</h2>
    <form id="changepassform" method="GET">
        <input type="hidden" id="action" name="action" value="changepass" />
        
        <div class="form-group">
            <label for="username">Username</label>
            <input type="text" id="username" name="username" required />
        </div>

        <div class="form-group">
            <label for="oldpassword">Current Password</label>
            <input type="password" id="oldpassword" name="oldpassword" required />
        </div>

        <div class="form-group">
            <label for="password">New Password</label>
            <input type="password" id="password" name="password" required />
            <small id="passwordFeedback" class="feedback"></small> 

        </div>

        <button type="submit">Verify</button>
    </form>
</div>

<script src="../js/changepassword.js"></script>
<script src="../com/clsAjax.js"></script>

</body>
</html>
