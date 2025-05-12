<?php

class Block {
    public $index;
    public $timestamp;
    public $transactions;
    public $previousHash;
    public $hash;

    public function __construct($index, $timestamp, $transactions, $previousHash = '') {
        $this->index = $index;
        $this->timestamp = $timestamp;
        $this->transactions = $transactions;
        $this->previousHash = $previousHash;
        $this->hash = $this->calculateHash();
    }

    public function calculateHash() {
        return md5($this->index . $this->timestamp . json_encode($this->transactions) . $this->previousHash);

        /////// hay una procedure que hashea en la base de datos, no se puede hashear dos veces
    }


    public function save(){
        global $DBcommand;
        $DBcommand->execute('AddBlock', array($this->previousHash, $this->hash));
        for ($i = 0; $i < count($this->transactions); $i++) {
            $currentBlock = $this->transactions[$i];
            $currentBlock->save($this->index);

            echo "<br> index de save block " . $this->index;
        }

    }


    public static function read() {
        global $DBcommand;
        
        $result = $DBcommand->execute('GetLastBlock', array());
        
        echo "<br><br> result: ";
        var_dump($result);
        if ($result && isset($result[0]['LastBlockID'])) {
            echo "result ultimo bloque: " . $result[0]['LastBlockID'] . "<br><br>";
            return $result[0]['LastBlockID']; //alias en la sp
        } 

        return 0; // No hay bloques aún
        
    }
}

?>