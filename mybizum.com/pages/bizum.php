<?php
session_start();
$loggedUser = $_SESSION['username'] ?? null;
?>

<script>
    const sender = "<?php echo htmlspecialchars($loggedUser); ?>";
</script>


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
                <select id="receiver" name="receiver">
                    <option disabled selected>Selecciona un contacto</option>
                </select>
                <!-- <input style="cursor: default; user-select: none; pointer-events: none;" type="text" id="receiver" name="receiver" readonly class="no-select" /> -->
            </div>

            <div class="form-group">
                <label for="amount">amount</label>
                <input type="number" id="amount" name="amount" step="0.01" required>
            </div>
        </div>
       
        <button type="submit" value="sendbizum">send bizum</button>
    </form>

  
 
</div>


<script src="../js/bizum.js"></script>
<script src="../js/contacts.js"></script>
<script src="../com/clsAjax.js"></script>

</body>
</html>
