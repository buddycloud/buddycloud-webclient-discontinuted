BOSH_SERVICE = 'http://bosh.metajack.im:5280/xmpp-httpbind'
Connector = require('connectors/connector').Connector
User = require('models/user').User

class exports.ConnectionHandler

  constructor : ->
    _.extend @, Backbone.Events
    
    @connected = false
    @connection = new Strophe.Connection(BOSH_SERVICE)
    
    @connector = new Connector(@connection)
    
    # for debug purposes only
    @bind "all", (status) -> app.debug "connection_event", status

  # connect the current user with his jid and pw
  connect : (jid, password) ->
    @user = new User( "jid" : jid )
    @connection.connect jid, password, @connection_event
    
  # forwards all events of the connection
  connection_event : (status) =>
    
    if status == Strophe.Status.CONNECTING
      @trigger 'connecting'

    else if status == Strophe.Status.AUTHFAIL
      @trigger 'authfail'

    else if status == Strophe.Status.CONNFAIL
      @connected = false
      @trigger 'connfail'

    else if status == Strophe.Status.DISCONNECTING
      @trigger 'disconnecting'

    else if status == Strophe.Status.DISCONNECTED
      @connected = false
      @trigger 'disconnected'

    else if status == Strophe.Status.CONNECTED
      @connected = true
      @after_connected()
      @trigger 'connected'
  
  after_connected : =>
    app.debug "after connect"
    @connector.announcePresence @user
    @connection.addHandle =>
      app.debug "onIq", arguments
    , null, 'iq'