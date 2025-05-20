<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
// require_once 'com/utils/blockchain/block.php';
// require_once 'com/utils/blockchain/blockchain.php';
// require_once 'com/utils/blockchain/transaction.php';
// require_once 'com/db/DBCommand.php';

class bizum
{
    private $DBCommand;

    public function __construct($DBCommand)
    {
        $this->DBCommand = $DBCommand;

    }

    // public function getBalance($username,$action){
    //     try {
    //         $result = $this->dbCommand->execute('Get_Balance', array($username,$this->url(),$action));
    //         // Establecer el encabezado para XML
    //         header('Content-Type: text/xml');
    //         echo $result;

    //     }catch (PDOException $e) {
    //         echo 'Error: ' . $e->getMessage();
    //     }  
    // }

    public function sendBizum($sender, $receiver, $amount) {
        if ($amount > 0) {

            $xmlResponse = $this->checkSenderBalance($sender, $amount);

            $xml = simplexml_load_string($xmlResponse);
            if ($xml === false) {
                // Manejo de error si XML no se carga correctamente
                header('Content-Type: text/plain');
                echo "Error al procesar la respuesta XML.";
                exit;
            }

            $errorCode = (int)$xml->head->errors->error->num_error;

            if ($errorCode === 0) {
                // Balance suficiente
                echo "balance suficiente";
                // $this->__executeTransaction($sender, $receiver, $amount);
            } else {
                echo "balance insuficiente o error";
                // Balance insuficiente o error
                header('Content-Type: text/xml');
                echo $xmlResponse;
            }

            exit;
        } else {
            // Cantidad no válida
            echo "no se pueeee";
            // $this->__executeBizum($sender, $receiver, $amount); // En tu lógica actual, si es <= 0 lo ejecutas igual
        }
    }


    public function checkSenderBalance($sender, $amount){
        $result = $this->DBCommand->execute('sp_check_balance', array($sender, $amount));
        return $result;
    }


    // private function __executeTransaction($sender, $receiver, $amount){
       
    //     $myBlockchain = new Blockchain();
    //     $lastblock = Block::read();
    //     $transaction = new Transaction($sender, $receiver, $amount);
     
    //     $block = new Block($lastblock+1, date("Y-m-d H:i:s"), [$transaction], '');

    //     $myBlockchain->addBlock($block);
    //     $myBlockchain->save();
       
    //     if ($myBlockchain->isChainValid()) {
    //         echo "La cadena es correcta! ";
            
    //         $this->__executeBizum($sender, $receiver, $amount);
            
    //         return;
    //     } else {
    //         echo "la cadena NO es correcta!";
    //     }

    // }
    

    // private function __executeBizum($sender, $receiver, $amount){
     
    //     $result = $this->DBCommand->execute('sp_create_bizum', array($sender, $receiver, $amount));

    //     header('Content-Type: text/xml');
    //     echo $result;
    //     exit;
    
    // }


    // public function viewTransaction($sender,$action){
        
    //     $result = $this->dbCommand->execute('ViewUserTransactions', array($sender,$this->url(),$action));
      
    //     header('Content-Type: text/xml');
    //     echo $result;
       
    // }

    // public function url()
    // {
    // // Obtener el protocolo
    // $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http';
    
    // // Obtener el host y la URI de la solicitud
    // $host = $_SERVER['HTTP_HOST'];
    // $requestUri = $_SERVER['REQUEST_URI'];

    // // Concatenar todo para obtener la URL completa
    // $url = $protocol . '://' . $host . $requestUri;

    // return $url;
    // }

    // public function method(){
    //     $method = $_SERVER['REQUEST_METHOD'];
    //     return $method;
    // }

 
}
?>