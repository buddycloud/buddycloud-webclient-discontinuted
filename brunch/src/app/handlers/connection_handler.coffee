BOSH_SERVICE = 'http://bosh.metajack.im:5280/xmpp-httpbind'
Connector = require('connectors/connector').Connector
User = require('models/user').User

class exports.ConnectionHandler

  constructor : ->
    _.extend @, Backbone.Events
    
    @connected = false
    @connection = new Strophe.Connection(BOSH_SERVICE)
    
    #
    temp = @connection.send
    @connection.send = (stanza) =>
      app.debug "dd", Strophe.serialize stanza
      temp.apply @connection, arguments
    
    
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
    @connector.announcePresence @user
    
    @connector.getUserSubscriptions @user, ->
      app.debug "gus_succ", arguments
    , ->
      app.debug "gus_error", arguments
    
    
    @connection.addHandler (stanza) ->
      app.debug "onIq", stanza, $(stanza).find('item')
      posts = for item in $(stanza).find('item')
        @_parse_post($(item))


      app.debug "posts", posts
      # for obj in posts
      #   if Posts.get(obj.id)
      #     # do nothing
      #   else
      #     p = new Post(obj)
      #     Posts.add(p)
      #     p.save()
          
    , null, 'iq'
    return true

  _parse_post : (item) ->
    post = { 
      id : parseInt(item.find('id').text().replace(/.+:/,''))
      content : item.find('content').text() 
      author : item.find('author jid').text()
      published : item.find('published').text()
    }

    if item.find 'in-reply-to'
      post.in_reply_to = parseInt(item.find('in-reply-to').attr('ref'))

    if item.find 'geoloc'
      post.geoloc_country = item.find('geoloc country').text()
      post.geoloc_locality = item.find('geoloc locality').text()
      post.geoloc_text = item.find('geoloc text').text()

    post