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


    public function save($DBCommand){ 
        // Guardar el bloque y recoger el BlockID devuelto
        $blockID = $DBCommand->execute('AddBlock', array($this->previousHash, $this->hash));

        // Guardar cada transacción asociada al bloque con el BlockID real
        for ($i = 0; $i < count($this->transactions); $i++) {
            $currentTransaction = $this->transactions[$i];
            $currentTransaction->save($blockID, $DBCommand);
            echo "<br> Guardando transacción en bloque con ID real de base de datos: " . $blockID;
        }
    }


    public static function read($DBCommand) {
        $result = $DBCommand->execute('GetLastBlock', array());

        if ($result && isset($result[0]['LastBlockID'])) {
            return $result[0]['LastBlockID'];
        }
        return 0;
    }

    
}

?>