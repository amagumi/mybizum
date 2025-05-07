<?php

session_start();

require_once 'com/utils/dao/connectDB.php';
require_once 'com/utils/dao/DBCommand.php';
require_once 'com/utils/dao/DBManager.php';
require_once 'com/utils/mailtools/mail_sender.php';
require_once 'com/security/UserManager.php';


// Crear una instancia de DBCommand

// //Conexion sql pol
$connection = new DBConnection('172.17.0.4,1433', 'PP_DDBB', 'SA', '<Alba123>');

//Conexion sql pau
// $connection = new DBConnection('172.17.0.3,1433', 'PP_DDBB', 'sa', 'P@ssw0rd');

$pdoObject = $connection->getPDOObject();

// Crear una instancia de DBCommand pasando el objeto PDO
$dbCommand = new DBCommand($pdoObject);

// $dbCommand = new DBCommand($pdoObject);

// Crear instancias de los gestores de usuario y base de datos
$userManager = new UserManager($dbCommand);
$dbManager = new DBManager($dbCommand);

$action = isset($_GET['action']) ? $_GET['action'] : '';

if (empty($action)) {
    echo "Accion no especificada.";
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

// Register:
//http://localhost:40080/M07/app-login/Front-end/ws.php?action=register&username=alex&name=alex&lastname=bujardon&password=Test12345!!&email=alex@gmail.com
// localhost:40080/gen-web/gen-web/PHP/ws.php?action=register&username=polrabascall&name=Pol&lastname=Rabascall&password=Test12345!!&email=polrabascall@gmail.com
// http://localhost:40080/gen-web/PHP/ws.php?action=register&username=PauAllendee&name=Pau&lastname=Allende&password=C0ntraseña2004!!&email=pauallendeherraiz@gmail.com

// Account Validate:
// http://localhost:40080/gen-web/gen-web/PHP/ws.php?action=accvalidate&username=polrabascall&code=
// http://localhost:40080/gen-web/PHP/ws.php?action=accvalidate&username=PauAllendee&code=40381

// Login: 
//http://localhost:40080/M07/app-login/Front-end/ws.php?action=login&username=alex&password=Test12345!!
// localhost:40080/gen-web/gen-web/PHP/ws.php?action=login&username=polrabascall&password=Test12345!!
// http://localhost:40080/gen-web/PHP/ws.php?action=login&username=PauAllendee&password=C0ntraseña2004!!

// Logout: 
// localhost:40080/gen-web/gen-web/PHP/ws.php?action=logout
// http://localhost:40080/gen-web/PHP/ws.php?action=logout

// Change Password:
// localhost:40080/gen-web/gen-web/PHP/ws.php?action=changepass&username=polrabascall&password=Test12345!!&newpassword=NewPassword12345!!
// http://localhost:40080/gen-web/PHP/ws.php?action=changepass&username=PauAllendee&password=C0ntraseña2004!!&newpassword=NewPassword12345!!

// View Active Connections: 
// localhost:40080/gen-web/gen-web/PHP/ws.php?action=viewcon
// http://localhost:40080/gen-web/PHP/ws.php?action=viewcon

// View Historical Connections: 
//localhost:40080/gen-web/gen-web/PHP/ws.php?action=viewconhist
// http://localhost:40080/gen-web/PHP/ws.php?action=viewconhist


//localhost:40080/gen-web/gen-web/PHP/ws.php?action=listusers&ssid=a0b39afe-6971-4d0c-85ca-d63bb5d07de2

//Verificar si la password cumple los requisitos
//http://localhost:40080/M07/app-login/Front-end/ws.php?action=checkpwd&password=testt
