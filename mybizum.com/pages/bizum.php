<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../css/styles.css">
    <title>Bizum</title>
    
</head>
<body>

<div class="container">
    <h2>Send Bizum</h2>
    <form action="action" id="bizumform"> 
        <input type="hidden" id="action" name="action" value="sendbizum">
        
        <div style="display: flex; flex-direction: row">
             <div class="form-group">
                <label for="receiver">receiver</label>
                <input type="text" id="receiver" name="receiver" required>
            </div>

            <div class="form-group">
                <label for="amount">amount</label>
                <input type="amount" id="amount" name="amount" required>
            </div>
        </div>
       

        <button type="submit" value="send bizum">send bizum</button>
    </form>

    <div class="container">
        <div class="button-container-vertical">
            <button onclick="window.location.href=''">historial</button>
        </div>
    </div>
    <div class="container">
        <div class="button-container-vertical">
    <p> lista de contactos </p>
        <select>holas
            <option value ='1'>1</option>
            <option value ='2'>2</option>
            <option value ='3'>3</option>
        </select>
        </div>
    </div>
</div>


<script src="../js/bizum.js"></script>
<script src="../com/clsAjax.js"></script>

</body>
</html>
