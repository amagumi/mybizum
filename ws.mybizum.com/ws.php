<?php

session_start();

require_once 'com/utils/dao/connectDB.php';
require_once 'com/utils/dao/DBCommand.php';
require_once 'com/utils/dao/DBManager.php';
require_once 'com/utils/mailtools/mail_sender.php';
require_once 'com/security/UserManager.php';
require_once 'com/bizum/clsBizum.php';


$connection = new DBConnection('172.17.0.4,1433', 'PP_DDBB', 'SA', '<Alba123>');
$pdoObject = $connection->getPDOObject();


$dbCommand = new DBCommand($pdoObject);
$userManager = new UserManager($dbCommand);
$dbManager = new DBManager($dbCommand);
$bizum = new bizum($dbCommand);

$action = isset($_GET['action']) ? $_GET['action'] : '';



if (empty($action)) {
    echo "Accion no especificada.";
    echo "Accion no especificada.<br>";
    echo isset($_SESSION['username'])
        ? 'User Online: ' . $_SESSION['username'] . '<br><br>'

        : 'Ningún usuario logueado<br><br>';

    echo "Ejemplo de uso: <br>";
    echo 'http://ws.mybizum.com:8080/com/ws.php?action=login&username=admin&password=1234' . '<br><br> <strong>Usuario sin ROLL USER </strong><br>';
    echo 'http://ws.mybizum.com:8080/com/ws.php?action=login&username=Manu&password=Cambio@1234' . '<br><br>';
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
    echo 'http://ws.mybizum.com:8080/com/ws.php?action=transaction&sender=admin&receiver=Manu&amount=10' . '<br>';
    echo 'http://ws.mybizum.com:8080/com/ws.php?action=viewTransaction&username=admin' . '<br>';

    // header("Location: ../Front-end/UI/mainUI.php");
    return;
} else {
    switch ($action) {
        case "register":
            $userManager->register($_GET['username'], $_GET['name'], $_GET['lastname'], $_GET['password'], $_GET['email']);
            break;
        // el register2 es lo mismo que el normal
        case "register2":
            $username = $_GET['username'];
            $name = $_GET['name'];
            $lastname = $_GET['lastname'];
            $password = $_GET['password'];
            $email = $_GET['email'];
            $userManager->register($username, $name, $lastname, $password, $email);
            break;
        case "login":
            $userManager->login($_GET['username'], $_GET['password']);
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
        case "listusers":
            $userManager->listusers($_GET['ssid']);
        case "checkpwd":
            $userManager->checkpwd($_GET['password']);       
            break;

        default:
            echo "Acción no válida.";
            break;
    }
}
