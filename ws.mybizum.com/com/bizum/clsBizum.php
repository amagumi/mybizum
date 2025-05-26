<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
require_once 'com/utils/blockchain/block.php';
require_once 'com/utils/blockchain/blockchain.php';
require_once 'com/utils/blockchain/transaction.php';


class bizum
{
    private $DBCommand;

    public function __construct($DBCommand)
    {
        $this->DBCommand = $DBCommand;

    }


    public function sendBizum($ssid, $receiver, $amount) {
        if ($amount > 0) {
            // $result = $this->checkBalance($ssid, $amount);
            // echo $result;
            
            // if ($result == 0) {
                // echo "balance suficiente";
                $this->__executeTransaction($ssid, $receiver, $amount);
            // } else {
                // echo "balance insuficiente o error (código: $result)";
            
        } else {
            // Cantidad no válida
            echo "no se pueeee";
        }
    }


    public function checkBalance($ssid, $amount) {
        $result = $this->DBCommand->execute('sp_check_balance2', [$ssid, $amount]);
        return $result;
    }


    private function __executeTransaction($ssid, $receiver, $amount){
        // echo "hola" . "<br><br>";
        $myBlockchain = new Blockchain();
        $lastblock = Block::read($this->DBCommand);
        $transaction = new Transaction($ssid, $receiver, $amount);

        // var_dump($myBlockchain);
        // echo "<br><br>";
        // var_dump($lastblock);
        // echo "<br><br>";
        // var_dump($transaction);
        // echo "<br><br>";

        $block = new Block($lastblock+1, date("Y-m-d H:i:s"), [$transaction], '');

        // echo "echo de block: ";
        // echo "<pre>";
        // print_r($myBlockchain);
        // echo "</pre>";

        
        $myBlockchain->addBlock($block);
        
        // Pasamos el DBCommand a save para que pueda ejecutar las consultas
        $myBlockchain->save($this->DBCommand);
        //die;////////////////////
       
        if ($myBlockchain->isChainValid()) {
            // echo "La cadena es correcta! ";
            
            $this->__executeBizum($ssid, $receiver, $amount);
            
            return;
        } else {
            // echo "la cadena NO es correcta!";
        }

    }

    
    // public function getBalance($sender) {
    //     $result = $this->DBCommand->execute('sp_get_balance', [$sender]);
    //     return $result;
    // }
    

    private function __executeBizum($ssid, $receiver, $amount){
     
        $result = $this->DBCommand->execute('sp_create_bizum2', array($ssid, $receiver, $amount));
        header('Content-Type: text/xml');
        echo $result;
    }

 
    public function getTransactions($ssid){
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
        // echo $ssid;

        // $username = $_SESSION['username'] ?? null;

        if (!$ssid) {
            header('Content-Type: application/json');
            echo json_encode(['error' => 'No hay usuario logueado']);
            return;
        }

        try {
            // Pasamos $username como parámetro al stored procedure
            $result = $this->DBCommand->execute('sp_get_transactions2', array($ssid));

            header('Content-Type: text/xml');
            echo $result;

        } catch (PDOException $e) {
            header('Content-Type: application/json');
            echo json_encode(['error' => $e->getMessage()]);
        }
    }

}
?>