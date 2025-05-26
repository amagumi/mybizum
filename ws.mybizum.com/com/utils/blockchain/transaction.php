<?php

class Transaction 
{
    // public $sender;
    public $ssid;
    public $receiver;
    public $amount;

    public function __construct ($ssid, $receiver, $amount) {
        // $this->sender = $sender;
        $this->ssid = $ssid;
        $this->receiver = $receiver;
        $this->amount = $amount;
    }
    
    // Recibe $DBCommand para ejecutar el stored procedure
    public function save($index, $DBCommand){
        $DBCommand->execute('AddTransaction2', array($this->ssid, $this->receiver, $this->amount, $index));
        // echo "resultado de transaccion: " . $this->sender . ', ' . $this->receiver . ', ' . $this->amount . ', ' . $index . "<br>";
    }
}


?>    