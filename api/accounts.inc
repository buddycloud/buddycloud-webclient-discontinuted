<?php

  class AccountsException extends Exception{
  }

  class Accounts{

    public function __construct($host){
      $this->host = $host;
      $this->command = "/usr/sbin/ejabberdctl";
    }
    
    public function register($user, $password){
      $command = $this->command . " register " . escapeshellarg($user) . " " . escapeshellarg($this->host) . " " . escapeshellarg($password);
    }

    public function remove($node){
      $command = $this->command . " unregister " . escapeshellarg($user) . " " . escapeshellarg($this->host);
    }
    
    public function changePassword($node, $password){
      $command = $this->command . " change_password " . escapeshellarg($user) . " " . escapeshellarg($this->host) . " " . escapeshellarg($password);
    }
    
  }
  
?>