<?php

class Transaction 
{
    public $sender;
    public $receiver;
    public $amount;

    public function __construct ($sender, $receiver, $amount) {
        $this->sender = $sender;
        $this->receiver = $receiver;
        $this->amount = $amount;
    }
    
    // Recibe $DBCommand para ejecutar el stored procedure
    public function save($index, $DBCommand){
        $DBCommand->execute('AddTransaction', array($this->sender, $this->receiver, $this->amount, $index));
        echo "resultado de transaccion: " . $this->sender . ', ' . $this->receiver . ', ' . $this->amount . ', ' . $index . "<br>";
    }
}


?>    