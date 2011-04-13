<?

  require 'user.inc';
  require 'config.inc';

  # Require http auth...
  function requestAuthCredentials(){
    header('WWW-Authenticate: Basic realm="Web client api"');
    header('HTTP/1.0 401 Unauthorized');
    echo 'You must authenticate to use this API';
  }
  
  # Client must authentiate every request with jid / password
  if (!isset($_SERVER['PHP_AUTH_USER'])) {

    requestAuthCredentials();
    die();

  } else {
    # Create the currentUser object
    $currentUser = new User($_SERVER['PHP_AUTH_USER']);
    
    # If the _SESSION['jid'] has been set and it matches the 
    # httpauth credentials, then the user is good to go. If
    # _SESSION hasn't been set, then we have to authenticate
    # the username and password using user#authenticate (which
    # uses xmppphp in turn).
    if($_SESSION['jid'] != $currentUser->getJid()){
      try {
        $valid = $currentUser->authenticate($_SERVER['PHP_AUTH_PW']);
      } catch(AuthException $e) {
        # Unable to contact the jabber server to authenticate - try again later.
        header("HTTP/1.1 503 Service Unavailable");
        echo "Service unavailable. Try again later.";
        die();
      }
        
      # Did the jid/password check out?
      if ($valid){
        $_SESSION['jid'] = $currentUser->getJid();
      else{
        requestAuthCredentials();
        die();
      }
    }
  }
  
  # Respond to different endpoints...
  $endpoint = $_GET['endpoint'];

  if$("email" == $endpoint){
    $data = json_decode($_POST['data']);
    
    foreach($data as $email){
      $recipient = $email['recipient'];
      $subject = $email['subject'];
      $message = $email['message'];
      $from = $currentUser->getJid();
      $domain = $currentUser->getDomain();
      
      $headers = 'From: ' . $from . "\r\n" .
        'Reply-To: no-reply@ ' . $domain . . "\r\n" .
        'X-Mailer: Buddycloud web client';
                
      mail($recipient, $subject, $message, $headers);
    }
    
    echo json_encode(array("success" => true));
    exit();
  }
  
  
  
  

?>