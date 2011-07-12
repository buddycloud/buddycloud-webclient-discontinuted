BOSH_SERVICE =  'http://bosh.metajack.im:5280/xmpp-httpbind'
DOMAIN = "buddycloud.com"
{ Connector } = require('connectors/connector')
{ DataHandler } = require('handlers/data_handler')
{ User } = require('models/user')

class exports.ConnectionHandler

  constructor : ->
    _.extend @, Backbone.Events

    @connected = false
    @connection = new Strophe.Connection(BOSH_SERVICE)

    # debugging
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
    @user = new User({jid})
    @connection.connect jid, password, @connection_event

  register : (username, password) ->
    @user = new User(jid:"#{username}@#{DOMAIN}")
    @connection.register.connect DOMAIN, (status, moar...) =>

      if status is Strophe.Status.REGISTERING
        @trigger 'registering'

      else if status is Strophe.Status.REGIFAIL
        @trigger 'regifail'

      else if status is Strophe.Status.REGISTER
        @trigger 'register'
        @connection.register.fields.username = username
        @connection.register.fields.password = password
        @connection.register.submit()

      else if status is Strophe.Status.SUBMITTING
        @trigger 'submitting'

      else if status is Strophe.Status.SBMTFAIL
        @trigger 'sbmtfail'
        @connection.register.authenticate() if @connection.register.registered

      else if status is Strophe.Status.REGISTERED
        @trigger 'registered'
        @connection.register.authenticate()

      else @connection_event.apply(this, arguments)

  isRegistered : () =>
    @connection.register.registered

  # forwards all events of the connection
  connection_event : (status) =>

    if status is Strophe.Status.ERROR
      @trigger 'error'

    else if status is Strophe.Status.CONNECTING
      @trigger 'connecting'

    else if status is Strophe.Status.CONNFAIL
      @connected = false
      @trigger 'connfail'

    else if status is Strophe.Status.AUTHENTICATING
      @trigger 'authenticating'

    else if status is Strophe.Status.AUTHFAIL
      @trigger 'authfail'

    else if status is Strophe.Status.CONNECTED
      @connected = true
      @announce_presence()
      @trigger 'connected'

    else if status is Strophe.Status.DISCONNECTED
      @connected = false
      @trigger 'disconnected'

    else if status is Strophe.Status.DISCONNECTING
      @trigger 'disconnecting'

    else if status is Strophe.Status.ATTACHED
      @trigger 'attached'

  announce_presence : =>
    @connector.announcePresence @user