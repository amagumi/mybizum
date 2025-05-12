<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);


// AGREGAR LAS RUTAR DEL BLOCKCHAINNNNN VAOS POR AQUI
class bizum
{
    private $dbCommand;


    public function __construct($dbCommand)
    {
        $this->dbCommand = $dbCommand;

    }

    public function getBalance($username,$action){
        try {
            $result = $this->dbCommand->execute('Get_Balance', array($username,$this->url(),$action));
            // Establecer el encabezado para XML
            header('Content-Type: text/xml');
            echo $result;

        }catch (PDOException $e) {
            echo 'Error: ' . $e->getMessage();
        }  
    }

    public function sendBizum($sender,$reciever,$amount,$pdoObject,$action){
       
        if ($amount <= 0){
            //no ejecutará el bizum por ser  menor a 0 desde la procedure sp_wdev_create_bizzum
            $this->__executeBizum($sender, $reciever, $amount,$action);
            return;
        }
        
        $xmlResponse = $this->checkAmountSender($sender, $amount,$action);
     
         // Carga y lee el XML
        $xml = simplexml_load_string($xmlResponse);
        $errorCode = (int)$xml->head->errors->error->num_error;
      
        if ($errorCode === 0){
            //Balance ok
           
           $this->__executeTransaction($sender, $reciever, $amount,$pdoObject,$action);
           exit; 
           
        }else{//Balance insuficiente
            
            header('Content-Type: text/xml');
            echo $xmlResponse;
            exit;            
        }
  
    }

    public function checkAmountSender($sender,$amount,$action){
        $result = $this->dbCommand->execute('CheckAmount', array($sender,$amount,$this->url(),$action));
        
        return $result;
    }

    private function __executeTransaction($sender, $reciever, $amount,$pdoObject,$action){
       
        $myBlockchain = new Blockchain($this->dbCommand,$pdoObject);
        
        $transaction1 = new Transaction($this->dbCommand,$sender, $reciever, $amount,$this->url(),$action);
     
        $latestIndex= $myBlockchain->getLatestBlock()->index;
        $newBlockId = $latestIndex + 1;

        $block = new Block($this->dbCommand,$newBlockId, null, [$transaction1]);
        
        $myBlockchain->addBlock($block);
        
        //////////////// $myBlockchain->addTransaction($transaction1,$newBlockId);
       
        if ($myBlockchain->isChainValid()) {
            //echo "La cadena es correcta! ";
            
            $this->__executeBizum($sender, $reciever, $amount,$action);
            
            return;
        } else {
            //echo "la cadena NO es correcta!";
        }

    }
    
    private function __executeBizum($sender, $reciever, $amount,$action){
     
        $result = $this->dbCommand->execute('sp_wdev_create_bizzum', array($sender,$reciever,$amount,$this->url(),$action));
       
        
        header('Content-Type: text/xml');
        echo $result;
        exit;
    
    }

    public function viewTransaction($sender,$action){
        
        $result = $this->dbCommand->execute('ViewUserTransactions', array($sender,$this->url(),$action));
      
        header('Content-Type: text/xml');
        echo $result;
       
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

    public function method(){
        $method = $_SERVER['REQUEST_METHOD'];
        return $method;
    }

 
}