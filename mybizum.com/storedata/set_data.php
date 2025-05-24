<?php
session_start();

if (isset($_POST['balance'])) {
    $_SESSION['balance'] = $_POST['balance'];
}

if (isset($_POST['username'])) {
    $_SESSION['username'] = $_POST['username'];
}
