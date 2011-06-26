BOSH_SERVICE = 'http://bosh.metajack.im:5280/xmpp-httpbind'
Connector = require('connectors/connector').Connector
DataHandler = require('handlers/data_handler').DataHandler
User = require('models/user').User

class exports.ConnectionHandler

  constructor : ->
    _.extend @, Backbone.Events
    
    @connected = false
    @connection = new Strophe.Connection(BOSH_SERVICE)
    
    #
    temp = @connection.send
    @connection.send = (stanza) =>
      app.debug Strophe.serialize stanza
      temp.apply @connection, arguments
    
    
    @connector = new Connector(@connection)
    app.handlers.data_handler = new DataHandler(@connector, @connection)
    
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
      @announce_presence()
      @trigger 'connected'
  
  announce_presence : =>
    @connector.announcePresence @user