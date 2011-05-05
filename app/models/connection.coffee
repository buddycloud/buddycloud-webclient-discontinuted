BOSH_SERVICE = 'http://bosh.metajack.im:5280/xmpp-httpbind'

class Connection
  constructor: ->
    @connected = false
    @roster = new UserCollection
    @roster.localStorage = new Store("Roster")
    @roster.fetch()
    
    _.extend(@, Backbone.Events)

  connect: (jid, password)->
    @c = new Strophe.Connection(BOSH_SERVICE)
  
    @jid = jid
    @password = password
    @user = Users.findOrCreateByJid(@jid)
    @connector = new Connector(@c)
    
    # After we are connected - do stuff
    @bind 'connected', @afterConnected
    @c.connect @jid, @password, @onConnect
  
  # Convert the strophe messages to backbone bind/trigger events
  onConnect: (status) =>
    if (status == Strophe.Status.CONNECTING)
      @trigger('connecting')

    else if (status == Strophe.Status.AUTHFAIL)
      @trigger('authfail')

    else if (status == Strophe.Status.CONNFAIL)
      @connected = false
      @trigger('connfail')

    else if (status == Strophe.Status.DISCONNECTING)
      @trigger('disconnecting')

    else if (status == Strophe.Status.DISCONNECTED)
      @connected = false
      @trigger('disconnected')

    else if (status == Strophe.Status.CONNECTED)
      @connected = true
      @trigger('connected')

  onIq: (iq) =>
    @connector.onIq(iq)
    true
    
  afterConnected: =>
    # Tell the pubsub service i'm here - (todo - find out which ones work)
    @connector.announcePresence(@user)

    # Listen for iq messages
    @c.addHandler @onIq, null, 'iq' # , null, null,  null); 
    
    true

this.Connection = Connection