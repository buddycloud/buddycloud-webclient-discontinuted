class Channel extends Backbone.Model
  initialize: ->
    @posts = PostCollection.forChannel(this)
    
  # The node id of this chanel
  getNode: ->
    @get('node')
    
  subscribe: ->
    request = $iq( { to : @pubsubService(), type : 'set' })
      .c('pubsub', { xmlns: Strophe.NS.PUBSUB })
      .c('subscribe', { node: @getNode(), jid : app.currentUser.getJid() })
    
    # Note that this shouldnt be set here - but we need a way to say that some UI is processing....
    @set { subscription : 'subscribed' }

    $c.c.sendIQ(
      request
      (response) =>
        # @set { subscription : 'subscribed' }
        # console.log 'response'
        # console.log response
      (err) =>
        console.log 'err'
        console.log err
    )
    
  unsubscribe: ->
    request = $iq( { to : @pubsubService(), type : 'set' })
      .c('pubsub', { xmlns: Strophe.NS.PUBSUB })
      .c('unsubscribe', { node: @getNode(), jid : app.currentUser.getJid() })

    # Note that this shouldnt be set here - but we need a way to say that some UI is processing....
    @set { subscription : null }

    $c.c.sendIQ(
      request
      (response) =>
        # console.log 'response'
        # console.log response
      (err) =>
        console.log 'err'
        console.log err
    )

  isSubscribed: ->
    @get('subscription') == 'subscribed'
    
  canPost: ->
    (@get('affiliation') == 'owner') || (@get('affiliation') == 'publisher') || (@get('default_affiliation') == 'publisher')

  pubsubService: ->
    "broadcaster.buddycloud.com"
    
  serviceProvider: ->
    "pubsub-bridge@#{@pubsubService()}"

  # Isn't a user node
  isStandalone: ->
    @getNode().match(/^.channel/)
    
  escapeCreationDate: ->
    @escape('creation_date').replace(/T.+/,'')
    
  hasMetaData: ->
    !!@get('owner')
    
  escapeOwnerNode: ->
    @escape('owner').replace(/@.+/,'')
    
  fetchPosts: ->
    if !$c.connected
      return
      
    request = $iq({ to : @serviceProvider(), type : 'get' })
      .c('pubsub', { xmlns : Strophe.NS.PUBSUB })
      .c('items', { node : @getNode() })
      
    $c.c.sendIQ(
      request,
      (response) =>
        @posts.parseResponse(response)
      (err) =>
        console.log 'err'
        console.log err
    )
    
  parseSubscription: (subscription) ->
    if subscription.attr('jid') != app.currentUser.getJid()
      throw "non-matching jid in channel#parseSubscription"
      
    @set {
      subscription : subscription.attr('subscription')
      affiliation : subscription.attr('affiliation')
    }
    
    this
    
  fetchMetadata: ->
    if !$c.connected
      return

    request = $iq( { "to" : @serviceProvider(), "type" : "get" })
      .c( "query", { "xmlns" : "http://jabber.org/protocol/disco#info", "node" : @getNode() })

    $c.c.sendIQ(
      request,
      (response) =>
        console.log response
        
        # Iterate over the fields and set on this object
        obj = {}
        for field in $(response).find('x field')
          key = $(field).attr('var').replace(/.+#/,'')
          value = $(field).text()

          obj[key] = value
          
        @set obj
        @save()
      (err) ->
        console.log 'error!'
        console.log err
    )

    # $c.getMetaData this
    
  getPosts: ->
    @fetchPosts()
    @posts

  getName: ->
    @get('node').replace(/.+\//,'')
    
this.Channel = Channel

class ChannelCollection extends Backbone.Collection
  model: Channel
  
  initialize: ->
    @localStorage = new Store("ChannelCollection")
  
  findByNode : (node) ->
    @find (channel) ->
      channel.get('node') == node
      
  getStandalone: ->
    channels = new Backbone.Collection
    channels.model = Channel

    channels.refresh(@select (channel) ->
      (channel.isStandalone()) && (channel.isSubscribed())
    )

    channels
    
  findOrCreateByNode : (node) ->
    channel = null
    
    if @findByNode(node)
      channel = @findByNode(node)
    else
      channel = new Channel {
        node : node
      }
      @add channel
      channel.save()

    channel

  # comparator: (post) ->
  #   post.get('published')

this.ChannelCollection = ChannelCollection
