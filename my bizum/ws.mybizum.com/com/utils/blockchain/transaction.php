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

    public function save($index){
        global $DBcommand;
        $DBcommand->execute('AddTransaction', array($this->sender, $this->receiver, $this->amount, $index));
    }
}

?>    