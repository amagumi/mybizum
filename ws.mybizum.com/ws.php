<?php

session_start();
// politica de cors
// Especifica el origen permitido (no usar "*")
$allowedOrigin = "http://mybizum.com:8080";
header("Access-Control-Allow-Origin: $allowedOrigin");  // Permitir el origen específico

// Permitir los métodos que se necesiten
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

// Permitir los encabezados necesarios
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Permitir el envío de credenciales
header("Access-Control-Allow-Credentials: true");

// Si la solicitud es OPTIONS (preflight), solo responder con 200
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Mostrar errores solo en desarrollo
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// importacion de archivos 
require_once 'com/utils/dao/connectDB.php';
require_once 'com/utils/dao/DBCommand.php';
require_once 'com/utils/dao/DBManager.php';
require_once 'com/utils/mailtools/mail_sender.php';
require_once 'com/security/UserManager.php';
require_once 'com/bizum/clsBizum.php';
// require_once 'com/utils/blockchain/block.php';
// require_once 'com/utils/blockchain/blockchain.php';
// require_once 'com/utils/blockchain/transaction.php';


$connection = new DBConnection('172.17.0.4,1433', 'PP_DDBB', 'SA', '<Alba123>');
$pdoObject = $connection->getPDOObject();
$dbCommand = new DBCommand($pdoObject);
$userManager = new UserManager($dbCommand);
$dbManager = new DBManager($dbCommand);
$bizum = new bizum($dbCommand);
// $myBlockchain = new Blockchain();


// switch global de acciones y solicitudes
$action = isset($_GET['action']) ? $_GET['action'] : '';
if (empty($action)) {
    echo "Accion no especificada.<br>";
    echo isset($_SESSION['username'])
        ? 'User Online: ' . $_SESSION['username'] . '<br><br>'

        : 'Ningún usuario logueado<br><br>';

// chuleta de manu
    echo "Ejemplo de uso: <br>";
    echo 'http://ws.mybizum.com:8080/com/ws.php?action=login&username=umi&password=Test12345!!' . '<br><br>';
    echo 'http://ws.mybizum.com:8080/com/ws.php?action=logout' . '<br>';
    echo 'http://ws.mybizum.com:8080/com/ws.php?action=CheckPasswordStrength&checkPassword=%27123456%27' . '<br>';
    echo 'http://ws.mybizum.com:8080/com/ws.php?action=register&username=pruebas&name=nomprova&lastname=provalast&password=123456&email=prueba@gmail.com&repassword=123456' . '<br>';
    echo 'http://ws.mybizum.com:8080/com/ws.php?action=changepass&username=admin&password=12354&newpassword=12345' . '<br>';
    echo 'http://ws.mybizum.com:8080/com/ws.php?action=viewcon' . '<br>';
    echo 'http://ws.mybizum.com:8080/com/ws.php?action=viewconhist' . '<br>';
    echo 'http://ws.mybizum.com:8080/com/ws.php?action=accvalidate&username=aure&code=84588' . '<br>';
    echo 'http://ws.mybizum.com:8080/com/ws.php?action=listusers&ssid=3464f0f6-1a35-4525-9667-c241e399ae42' . '<br>';
    echo 'http://ws.mybizum.com:8080/com/ws.php?action=balance&username=admin' . '<br><br>';
    echo 'TRANSACCIONES:' . '<br>';
    echo 'http://ws.mybizum.com:8080/com/ws.php?action=sendbizum&sender=asier&receiver=umi&amount=10' . '<br>';
    echo 'http://ws.mybizum.com:8080/com/ws.php?action=viewTransaction&username=admin' . '<br>';

    return;
} else {
    switch ($action) {
        case "register":
            $userManager->register($_GET['username'], $_GET['name'], $_GET['lastname'], $_GET['password'], $_GET['email']);
            break;
        case "login":
            $userManager->login($_GET['username'], $_GET['password'], $action);
            break;
        case "logout":
            $userManager->logout();
            break;
        case "changepass":
            $userManager->changePassword($_GET['username'], $_GET['password'], $_GET['newpassword']);
            break;
        case "viewcon":
            $dbManager->viewConnections();
            break;
        case "viewconhist":
            $dbManager->viewHistoricConnections();
            break;
        case "accvalidate":
            $userManager->accountValidate($_GET['username'], $_GET['code']);
            break;
        case "listusers":
            $userManager->listusers($_GET['ssid']);
            break;
        case "checkpwd":
            $userManager->checkpwd($_GET['password']);       
            break;
        case "sendbizum":
            $bizum->sendBizum($_GET['sender'], $_GET['receiver'], $_GET['amount']);    
            break;
        default:
            echo "Acción no válida.";
            break;
    }
}
