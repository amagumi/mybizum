<?php

class UserManager {
    private $dbCommand;

    public function __construct($dbCommand) {
        $this->dbCommand = $dbCommand;
    }

    public function register($username, $name, $lastname, $password, $email) {
        if (empty($username) || empty($name) || empty($lastname) || empty($password) || empty($email)) {
            echo "Todos los campos son obligatorios.";
        } else {
            try {
                $result = $this->dbCommand->execute('sp_user_register', array($username, $name, $lastname, $password, $email));

                $register_code = $this->dbCommand->execute('sp_wdev_get_registercode', array($username, 0));

                $url = 'https://script.google.com/macros/s/AKfycbzHHL6pycrumpsogGSHrp1Kv88lWHB7agA71VIaEpSkTNPJWYNoo_3vtCN0_SJgx-nNdA/exec';
                
                // Parámetros del correo electrónico
                $destinatario = $email;
                $asunto = 'Código de registro.';
                $cuerpo = $name . ', su código de verificación es ' . $register_code;
                $adjunto = null; 
                
                // Llamada a la función para enviar el correo
                $resultado = enviarCorreo($url, $destinatario, $asunto, $cuerpo, $adjunto);
                
                header('Content-Type: text/xml');

                // Mostrar la respuesta XML
                echo $result;
            } catch (PDOException $e) {
                echo 'Error: ' . $e->getMessage();
            }
        }
    }

    public function login($username, $password) {
    if (empty($username) || empty($password)) {
        echo "Todos los campos son obligatorios.";
        return;
    }

    try {
        $result = $this->dbCommand->execute('sp_user_login', array($username, $password));
        $_SESSION['username'] = $username;
        header('Content-Type: text/xml');
        echo $result;

        // OPCIONAL: si quieres convertirlo en array PHP o JSON, mira abajo

    } catch (PDOException $e) {
        echo 'Error: ' . $e->getMessage();
    }
}


    public function logout() {  
        try {
            if (isset($_SESSION['username'])) { 
                $username = $_SESSION['username'];
                $result = $this->dbCommand->execute('sp_user_logout', array($username));
                session_destroy();
                session_unset();
                //$sd = session_destroy();
                // Establecer el encabezado para XML
                header('Content-Type: text/xml');
                //echo $_SESSION['username'];
        
                // Mostrar la respuesta XML
                echo $result;
            }
        } catch (PDOException $e) {
            echo 'Error: ' . $e->getMessage();
        }
    }

    public function changePassword($username, $password, $newpassword) {
        if (empty($username) || empty($password)) {
            echo "Todos los campos son obligatorios.";
        } else {
            try {
                $result = $this->dbCommand->execute('sp_user_change_password', array($username, $password, $newpassword));

                // Establecer el encabezado para XML
                header('Content-Type: text/xml');

                // Mostrar la respuesta XML
                echo $result;
            } catch (PDOException $e) {
                echo 'Error: ' . $e->getMessage();
            }
        }
    }

    public function accountValidate($username, $code){
        if (empty($username) || empty($code)){
            echo "Todos los campos son obligatorios.";
        } else {
            try {
                $result = $this->dbCommand->execute('sp_user_accountvalidate', array($username, $code));

                // header('Location: ../../mybizum.com/pages/validateaccountresult.php');
                // Establecer el encabezado para XML
                header('Content-Type: text/xml');

                // Mostrar la respuesta XML
                echo $result;
                
            } catch (PDOException $e) {
                echo 'Error: ' . $e->getMessage();
            }
        }
    }

    public function listusers($ssid){
        if (empty($ssid)){
            echo "Todos los campos son obligatorios.";
        } else {
            try {
                $result = $this->dbCommand->execute('sp_list_users2', array($ssid));

                // Establecer el encabezado para XML
                header('Content-Type: text/xml');

                // Mostrar la respuesta XML
                echo $result;
                
            } catch (PDOException $e) {
                echo 'Error: ' . $e->getMessage();
            }
        }
    }
    public function checkpwd($password) {
        if (empty($password)) {
            echo "Todos los campos son obligatorios.";
        } else {
            try {
                $result = $this->dbCommand->execute('sp_user_register_check_pwd', array($password));
    
                header('Content-Type: text/xml');
                // Mostrar la respuesta XML
                echo $result;
    
            } catch (PDOException $e) {
                echo 'Error: ' . $e->getMessage();
            }
        }
    }
    
    public function url()
    {
        // Obtener el protocolo
        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http';

        // Obtener el host y la URI de la solicitud
        $host = $_SERVER['HTTP_HOST'];
        $requestUri = $_SERVER['REQUEST_URI'];

        // Concatenar todo para obtener la URL completa
        $url = $protocol . '://' . $host . $requestUri;

        return $url;
    }
    
}

?>
