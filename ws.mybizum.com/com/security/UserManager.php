<?php

class UserManager {
    private $DBCommand;

    public function __construct($DBCommand) {
        $this->DBCommand = $DBCommand;
    }


    public function register($username, $name, $lastname, $password, $email) {
        if (empty($username) || empty($name) || empty($lastname) || empty($password) || empty($email)) {
            echo "Todos los campos son obligatorios.";
        } else {
            try {
                $result = $this->DBCommand->execute('sp_user_register', array($username, $name, $lastname, $password, $email));
                // if ($result == 0){
                //     $this->getRegisterCode($username);
                // }
                // $url = 'https://script.google.com/macros/s/AKfycbzHHL6pycrumpsogGSHrp1Kv88lWHB7agA71VIaEpSkTNPJWYNoo_3vtCN0_SJgx-nNdA/exec';
                
                // // Parámetros del correo electrónico
                // $destinatario = $email;
                // $asunto = 'Código de registro.';
                // $cuerpo = $name . ', su código de verificación es ' . $register_code;
                // $adjunto = null; 
                
                // // Llamada a la función para enviar el correo
                // $resultado = enviarCorreo($url, $destinatario, $asunto, $cuerpo, $adjunto);
                
                header('Content-Type: text/xml');

                // Mostrar la respuesta XML
                echo $result;
            } catch (PDOException $e) {
                echo 'Error: ' . $e->getMessage();
            }
        }
    }


    public function getRegisterCode($username){
        $result = $this->DBCommand->execute('sp_wdev_get_registercode', [$username]);
        return $result;
    }


    public function login($username, $password) {
        if (empty($username) || empty($password)) {
            echo "Todos los campos son obligatorios.";
            return;
        }

        try {
            $result = $this->DBCommand->execute('sp_user_login', array($username, $password));
            $_SESSION['username'] = $username;
            header('Content-Type: text/xml');
            echo $result;

            // OPCIONAL: si quieres convertirlo en array PHP o JSON, mira abajo

        } catch (PDOException $e) {
            echo 'Error: ' . $e->getMessage();
        }
    }


    public function logout() {
        header('Content-Type: text/xml');

        try {
            if (isset($_SESSION['username'])) {
                $username = $_SESSION['username'];

                $result = $this->DBCommand->execute('sp_user_logout', array($username));

                session_unset();
                session_destroy();

                // Si el SP devuelve XML válido, lo imprimimos directamente
                echo $result;
            } else {
                // Si no hay sesión, devolver XML con error
                echo '<response><num_error>1</num_error><message>Sesión no iniciada</message></response>';
            }
        } catch (PDOException $e) {
            // Devolver error en XML
            echo '<response><num_error>2</num_error><message>' . htmlspecialchars($e->getMessage()) . '</message></response>';
        }
    }


    public function changePassword($username, $password, $newpassword) {
        if (empty($username) || empty($password)) {
            echo "Todos los campos son obligatorios.";
        } else {
            try {
                $result = $this->DBCommand->execute('sp_user_change_password', array($username, $password, $newpassword));

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
                $result = $this->DBCommand->execute('sp_user_accountvalidate', array($username, $code));

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


    public function listusers() {
        try {
            // Ejecutamos el stored procedure que devuelve XML
            $result = $this->DBCommand->execute('sp_list_users');

            // header debe ir antes de imprimir cualquier cosa
            header('Content-Type: text/xml');

            // Aquí asumimos que $result es string XML
            echo $result;

        } catch (PDOException $e) {
            // En caso de error devolver JSON o texto
            header('Content-Type: application/json');
            echo json_encode(['error' => $e->getMessage()]);
        }
    }


    public function checkpwd($password) {
        if (empty($password)) {
            echo "Todos los campos son obligatorios.";
        } else {
            try {
                $result = $this->DBCommand->execute('sp_user_register_check_pwd', array($password));
    
                header('Content-Type: text/xml');
                // Mostrar la respuesta XML
                echo $result;
    
            } catch (PDOException $e) {
                echo 'Error: ' . $e->getMessage();
            }
        }
    }

    
    public function url(){
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
