PUBSUB_BRIDGE = "pubsub-bridge@broadcaster.buddycloud.com"
BOSH_SERVICE = 'http://buddycloud.com/http-bind/'
BOSH_SERVICE = 'http://bosh.metajack.im:5280/xmpp-httpbind'

class Connection
  constructor: (jid, password) ->
    @connected = false
    @jid = jid
    @password = password
    
    _.extend(@, Backbone.Events)
    
    @c = new Strophe.Connection(BOSH_SERVICE)

    @c.rawInput = (message) ->
      c = if message.match(/<error/)
        'error'
      else
        'input'
      
      $("<div />").text(message).addClass(c).appendTo '#log'
    
    @c.rawOutput = (message) ->
      $("<div />").text(message).addClass('output').appendTo '#log'

    @maxMessageId = 1292405757510
  
    @bind 'connected', @afterConnected
    
  connect: ->
    @c.connect @jid, @password, @onConnect
    
  onConnect: (status) =>
    if (status == Strophe.Status.CONNECTING)
      @trigger('connecting')
      console.log('Strophe is connecting.')
    else if (status == Strophe.Status.AUTHFAIL)
      console.log('Strophe failed to authenticate.')
      app.signout()
    else if (status == Strophe.Status.CONNFAIL)
      console.log('Strophe failed to connect.')
      @connected = false
      # app.signout()
    else if (status == Strophe.Status.DISCONNECTING)
      console.log('Strophe is disconnecting.')
    else if (status == Strophe.Status.DISCONNECTED)
      console.log('Strophe is disconnected.')
      @trigger('disconnected')
      @connected = false
    else if (status == Strophe.Status.CONNECTED)
      @connected = true
      console.log('Strophe is connected.')
      @trigger('connected')

      # @c.disconnect()

  # getSubscriptions: (node) ->
  #   id = @c.getUniqueId("LM")
  # 
  #   stanza = $iq({"id":id, "to":PUBSUB_BRIDGE, "type":"get"})
  #     .c("pubsub", {"xmlns":"http://jabber.org/protocol/pubsub"})
  #     .c("subscriptions")
  # 
  #   # Request..
  #   @c.send(stanza.tree());
  # 
  #   id = @c.getUniqueId("LM")
  # 
  #   stanza = $iq({"id":id, "to":PUBSUB_BRIDGE, "type":"get"})
  #     .c("pubsub", {"xmlns":"http://jabber.org/protocol/pubsub"})
  #     .c("items")
  #     .c("set", {"xmlns":"http://jabber.org/protocol/rsm"})
  #     .c("after").t(@maxMessageId)
  # 
  #   # Request..
  #   @c.send(stanza.tree());
  #   
  
  sendPost: (post) ->
    id = @c.getUniqueId("LM")

    stanza = $iq({"id" : id, "to" : PUBSUB_BRIDGE, "type" : "set"})
      .c("pubsub", { "xmlns" : "http://jabber.org/protocol/pubsub" })
      .c("publish", {"node":post.get('channel')})
      .c("item")
      .c("entry", {"xmlns":"http://www.w3.org/2005/Atom"})
      .c("content", {"type" : "text"}).t(post.get("content")).up()
      .c("author")
      .c("jid", {"xmlns":"http://buddycloud.com/atom-elements-0"}).t(post.get("author")).up().up()
      .c("in-reply-to", { "xmlns" : "http://purl.org/syndication/thread/1.0", "ref" : post.get('in_reply_to') }).up()
      # ... geoloc ..

      
      # <link rel="license" type="text/html"
      #   href="http://creativecommons.org/licenses/by/2.5/" />      

    # console.log(stanza.tree())
    
    # Request..
    @c.send(stanza.tree());
    
    # console.log "sent!"
    
  getMetaData: (channel) ->
    id = @c.getUniqueId("LM");
    request = $iq( { "id" : id, "to" : PUBSUB_BRIDGE, "type" : "get" })
      .c( "query", { "xmlns" : "http://jabber.org/protocol/disco#info", "node" : channel.getNode() })

    # connection.addHandler(Pref.onNodeMetaData, 
    #                               EVERY_NAMESPACE, 
    #                               "iq", 
    #                               EVERY_IQ_TYPE, 
    #                               uniqueID, 
    #                               FROM_ANY_SERNDER);

    @c.send(request.tree())
    
  getAllChannels: ->
    stanza = $pres( { "to" : PUBSUB_BRIDGE } )
    
    stanza
      .c("set", {"xmlns":"http://jabber.org/protocol/rsm"})
      .c("after").t(@maxMessageId + "")
      # .up()
      # .c("max").t("100")
      # .up()
      # .c("before")

    @c.send stanza.tree()
    
  subscribeToUser: (jid) ->
    @c.send($pres( { "type" : "subscribe", "to" : jid } ).tree())
    
  unsubscribeFromUser: (jid) ->
    @c.send($pres( { "type" : "unsubscribe", "to" : jid } ).tree())
    
  getChannel: (node) ->
    id = @c.getUniqueId("LM")

    stanza = $iq({"id":id, "to":PUBSUB_BRIDGE, "type":"get"})
      .c("pubsub", {"xmlns":"http://jabber.org/protocol/pubsub"})
      .c("items", {"node":node})
      .c("set", {"xmlns":"http://jabber.org/protocol/rsm"})
      .c("after").t("100")

    # Request..
    @c.send(stanza.tree());
    
  onSubscriptionIq: (iq) =>
    # console.log iq
    true
    
    
  onMessage: (message) =>
    console.log 'message'
    console.log message

    true
    
  onPresence: (stanza) =>
    console.log 'presence'
    console.log stanza

    return
    
    stanza = $(stanza)
    
    jid = stanza.attr('from')
    type = stanza.attr('type')

    # # Subscription request from service?
    # if (jid.indexOf('@') < 0 && type === 'subscribe') {

    # Always allow
    @c.send($pres({ type: 'subscribed', to: jid }));

    presence = $(stanza)
    
    jid = presence.attr('from').replace(/\/.+/,'')
      
    user = if Users.findByJid(jid)
      Users.findByJid(jid)
    else
      user = new User {
        jid : jid
      }
      
      if presence.find('status')
        user.set { status : presence.find('status').text() }
      
      Users.add user
      
      user

    user.grantChannelPermissions()
             
    true

  grantChannelPermissions: (jid, node) ->
    id = @c.getUniqueId("LM")

    stanza = $iq({"id":id, "to":PUBSUB_BRIDGE, "type":"set"})
      .c("pubsub", {"xmlns":"http://jabber.org/protocol/pubsub"})
      .c("affiliations", { "node" : node })
      .c("affiliation", { "jid" : jid, affiliation : "follower+post" })

    @c.send(stanza.tree())

  onIq: (iq) =>
    for items in $(iq).find('items')
      channel = Channels.findOrCreateByNode($(items).attr('node'))

      for item in $(items).find('item')
        item = $(item)
      
        id = parseInt(item.find('id').text().replace(/.+:/,''))
      
        if (!Posts.get(id)) && (item.find('content'))
          post = new Post { 
            id : id
            content : item.find('content').text() 
            author : item.find('author jid').text()
            published : item.find('published').text()
          }
      
          if item.find 'in-reply-to'
            post.set { 'in_reply_to' : parseInt(item.find('in-reply-to').attr('ref')) }

          if item.find 'geoloc'
            post.set { 
              geoloc_country : item.find('geoloc country').text()
              geoloc_locality : item.find('geoloc locality').text()
              geoloc_text : item.find('geoloc text').text()
            }
        
          if post.valid()
            channel.posts.add(post)
            post.save()
          else
            # we dont display posts that have no content (looks ugly)...
    
    true
    
  # createMyChannel: ->
  #   id = @c.getUniqueId("LM")
  # 
  #   stanza = $iq({"id":id, "to":PUBSUB_BRIDGE, "type":"set"})
  #     .c("pubsub", {"xmlns":"http://jabber.org/protocol/pubsub"})
  #     .c("create", { "node" : app.currentUser.channelId() }).up()
  # 
  #   @c.send(stanza.tree())
  #   
  #   @grantChannelPermissions app.currentUser.get('jid'), app.currentUser.channelId()
    
  afterConnected: ->
    # @c.pubsub.setService(PUBSUB_BRIDGE)

    # Tell the pubsub service i'm here
    @c.send($pres().c('status').t('buddycloud channels'))
    @c.send($pres().tree())
    @c.send($pres( { "to" : PUBSUB_BRIDGE, "from" : app.currentUser.get('jid') } ).tree())
    @c.send($pres( { "type" : "subscribe", "to" : PUBSUB_BRIDGE } ).tree())
    @c.send($pres( { "type" : "subscribe", "to" : PUBSUB_BRIDGE, "from" : app.currentUser.get('jid') } ).tree())

    # Create channel for currentUser
    # @createMyChannel()

    # Add handlers for messages and iq stanzas

    # @c.addHandler (stanza) ->
    #   console.log 'recieved...'
    #   console.log Strophe.serialize(stanza)
    #   true

    console.log "After connection done..."
    
    # @c.addHandler(@onMessage, null, 'message', null, null,  null); 
    @c.addHandler @onIq, null, 'iq' # , null, null,  null); 
    # @c.addHandler(@onPresence, null, 'presence', null, null,  null); 

    @getAllChannels()

    # @getSubscriptions()
    # @getChannel(CHANNEL)

    # connection.pubsub.subscribe(CHANNEL_NODE, null, null, Rcf.onSubscriptionIq, true);
    # Rcf.requestNodeMetaData(CHANNEL_NODE);

    # @c.pubsub.subscribe(CHANNEL, null, @onSubscriptionIq, @eh);

    #@c.pubsub.subscribe(CHANNEL, null, @eh, @eh, @onSubscriptionIq, @eh);

    #         Client.connection.pubsub.subscribe(
    #           Client.connection.jid,
    # 'pubsub.' + Config.XMPP_SERVER,
    #           Config.PUBSUB_NODE,
    #           [],
    #           Client.on_event,
    #           Client.on_subscribe
    #         );


this.Connection = Connection