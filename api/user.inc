<?php

  # From http://code.google.com/p/xmpphp/
  include 'xmpphp/xmpp.php';

  # This is thrown when we are unable to authenticate the user due
  # to a system error
  class AuthException extends Exception{
  }

  # Check a users credentials via php. Note that this is a slow function
  # and should only be done infrequently.
  class User {
  
    public function __construct($jid){
      $this->jid = $jid;
    }

    public function authenticate($password){
      $this->conn = new XMPPHP_XMPP(
        $this->getDomain(), 
        5222, 
        $this->getNode(), 
        $password, 
        'xmpphp', 
        $this->getDomain(),
        $printlog=false, 
        $loglevel=XMPPHP_Log::LEVEL_VERBOSE
      );
    
      try {
        $this->conn->connect();
        $this->conn->processUntil('session_start');
        $this->conn->presence();

        return true;
      } catch(XMPPHP_Exception $e) {
        if($e->getMessage() == "Auth failed!"){
          return false;
        }else{
      		throw new AuthException('Unable to contact server - try again later');
        }
      }
    }
  
    public function getJid(){
      return $this->jid;
    }
    
    public function getNode(){
      return preg_replace('/@.+/', '', $this->jid);
    }
    
    public function getDomain(){
      $d = $this->jid;
      $d = preg_replace('/.+@/', '', $d);
      $d = preg_replace('/\/.+/', '', $d);
      return $d;
    }
  }
  
?>