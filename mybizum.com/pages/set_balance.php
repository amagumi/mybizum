<?php
session_start();

if (isset($_POST['balance'])) {
    $_SESSION['balance'] = $_POST['balance'];
}
