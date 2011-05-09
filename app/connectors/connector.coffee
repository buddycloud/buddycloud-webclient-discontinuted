class Connector
  constructor: (connection) ->
    @connection = connection

  # Only buddycloud afaik
  domain: ->
    "buddycloud.com"

  # The broadcaster
  pubsubService: ->
    "broadcaster.#{@domain()}"

  # The pubsub bridge jid
  pubsubJid: ->
    "pubsub-bridge@#{@pubsubService()}"

  # Add a user to your roster
  addUserToRoster: (jid) ->
    @connection.send($pres( { "type" : "subscribe", "to" : jid } ))

  # Remove a user from your roster
  removeUserFromRoster: (jid) ->
    @connection.send($pres( { "type" : "unsubscribe", "to" : jid } ))

  # Parse a roster
  # _parseRoster: (response) ->
  #   addItem = (item) =>
  #     user = @roster.findOrCreateByJid item.attr('jid')
  #     user.set { subscription : item.attr('subscription'), group : item.find('group:first').text()  }
  #     user.save()
  #   
  #   for item in response.find('item')
  #     addItem($(item))

  #
  # Subscription request
  #
  subscribeToChannel: (channel, user, succ, error) ->
    request = $iq( { to : @pubsubJid(), type : 'set' })
      .c('pubsub', { xmlns: Strophe.NS.PUBSUB })
      .c('subscribe', { node: channel.getNode(), jid : user.getJid() })

    @connection.sendIQ(
      request
      (response) =>
        if succ?
          succ true
      (e) =>
        if err?
          err e
    )

  # Get the subscriptions for a user, calls succ with an array of hashes of channels
  getUserSubscriptions: (user, succ, err) ->
    node = user.getNode()

    request = $iq({"to" : @pubsubJid(), "type":"get"})
      .c("pubsub", {"xmlns":"http://jabber.org/protocol/pubsub"})
      .c("subscriptions")

    # Request..
    @connection.sendIQ(
      request
      (response) ->
        channels = for subscription in $(response).find('subscription')
          {
            jid : $(subscription).attr('jid') + "@#{@domain()}"
            description : $(subscription).attr('description')
          }
        if succ?
          succ(channels)
      (e) ->
        if err?
          err($(e).find('error').attr('code'))
    )

  # Get metadata, calls succ with a hash of metadata
  getMetadata: (channel, succ, err)->
    request = $iq( { "to" : @pubsubJid(), "type" : "get" })
      .c( "query", { "xmlns" : "http://jabber.org/protocol/disco#info", "node" : channel.getNode() })

    @connection.sendIQ(
      request,
      (response) =>
        # Flatten the namespaced fields into a hash
        obj = {}
        for field in $(response).find('x field')
          key = $(field).attr('var').replace(/.+#/,'')
          value = $(field).text()
          obj[key] = value
        succ(obj)
      (e) ->
        if err?
          err($(e).find('error').attr('code'))
    )

  # Get channel posts, calls succ with a array of hashes of posts
  getChannelPosts: (channel, succ, err) ->
    request = $iq({ to : @pubsubJid(), type : 'get' })
      .c('pubsub', { xmlns : Strophe.NS.PUBSUB })
      .c('items', { node : channel.getNode() })

    @connection.sendIQ(
      request,
      (response) =>
        posts = for item in $(response).find('item')
          @_parsePost($(item))

        succ(posts)
      (e) =>
        if err?
          err($(e).find('error').attr('code'))
    )

  # Sends a presence stanza to the server, subscribing to new IQs
  announcePresence: (user) ->
    maxMessageId = "1292405757510"

    # Todo - find out which one of these works and delete the rest
    request = $pres( { "to" : @pubsubJid() } )
      .c("set", {"xmlns":"http://jabber.org/protocol/rsm"})
      .c("after").t(maxMessageId)
    @connection.send request
    @connection.send($pres().c('status').t('buddycloud channels'))
    @connection.send($pres().tree())
    @connection.send($pres( { "to" : @pubsubJid(), "from" : user.get('jid') } ).tree())
    @connection.send($pres( { "type" : "subscribe", "to" : @pubsubJid() } ).tree())
    @connection.send($pres( { "type" : "subscribe", "to" : @pubsubJid(), "from" : user.get('jid') } ).tree())
    
  onIq : (stanza) ->
    posts = for item in $(stanza).find('item')
      @_parsePost($(item))

    for obj in posts
      if Posts.get(obj.id)
        # do nothing
      else
        p = new Post(obj)
        Posts.add(p)
        p.save()
    
  # Takes an <item /> stanza and returns a hash of it's attributes
  _parsePost : (item) ->
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

@Connector = Connector
