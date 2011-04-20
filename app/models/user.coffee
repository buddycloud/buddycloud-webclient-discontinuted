class User extends Backbone.Model
  initialize: ->

  serviceProvider: ->
    "pubsub-bridge@broadcaster.buddycloud.com"

  getChannel: ->
    Channels.findOrCreateByNode @getNode()

  getNode: ->
    "/user/#{@get('jid')}/channel"
    
  # fetchPosts: ->
  #   if !$c.connected
  #     return
  # 
  #   # Discover...
  #   request = $iq({ to: @serviceProvider(), type: 'get' })
  #     .c('query', { xmlns: Strophe.NS.DISCO_ITEMS, node : @getNode() })
  #     
  #   $c.c.sendIQ(request)
  #   
  #   # Get....
  #   request = $iq({ to : @serviceProvider(), type : 'get' })
  #     .c('pubsub', { xmlns : Strophe.NS.PUBSUB })
  #     .c('items', { node : @getNode() })
  #     
  #   $c.c.sendIQ(
  #     request,
  #     (response) =>
  #       @posts.parseResponse(response)
  #     (err) =>
  #       console.log 'err'
  #       console.log err
  #   )
  #   
  
  hasNoChannel: ->
    (@getChannel().status == null) || (@getChannel().status == 'loading') || (@getChannel().status == '200')
    
  getJid: ->
    @get('jid')
    
  getFullName: ->
    # todo - implement me
    @getName().capitalize()
    
  getName: ->
    @get('jid').toString().replace /@.+/, ''

  getStatus: ->
    (@get('status') + "").replace(/<.+?>/g,'')
    
  # subscribe: ->
  #    #     this.request($iq({ to: jid,
  #    #       type: 'set' }).
  #    # c('pubsub', { xmlns: Strophe.NS.PUBSUB }).
  #    # c('subscribe', { node: node }),
  #    # 
  #    # 
  #   if $c.connected
  #     request = $iq( { to : @serviceProvider(), type : 'set' })
  #       .c('pubsub', { xmlns: Strophe.NS.PUBSUB })
  #       .c('subscribe', { node: @getNode() })
  #       
  #     console.log Strophe.serialize(request)
  #     $c.c.sendIQ(
  #       request
  #       (response) =>
  #         @posts.parseResponse(response)
  #       (err) =>
  #         console.log 'err'
  #         console.log err
  #     )
  # 
  #     # $c.c.send($pres( { "type" : "subscribe", "to" : @getJid() } ).tree())
  #     # $c.subscribeToUser @get('jid')
  # 
  # unsubscribe: ->
  #   if $c.connected
  #     $c.c.send($pres( { "type" : "unsubscribe", "to" : @get('jid') } ).tree())
  
  # grantChannelPermissions: ->
  #   if $c.connected
  #     $c.grantChannelPermissions @get('jid'), @getNode()

  # addFriend: (jid) ->
  #   if ! @get('friends')
  #     @set { friends : [] }
  # 
  #   for j in @get('friends') when jid == j
  #     # already exists...
  #     return
  #     
  #   @attributes.friends.push jid
  #   
  # # more like the roster...
  # getFriends: ->
  #   if ! @get('friends')
  #     @set { friends : [] }
  # 
  #   for jid in @get('friends')
  #     Users.findOrCreateByJid jid
    
  getAvatar: ->
    if @get('jid').toString().match /@buddycloud/
      "http://media.buddycloud.com/channel/54x54/buddycloud.com/#{@getName()}.png"
    else
      "http://www.gravatar.com/avatar/#{hex_md5(@get('jid'))}?d=http://diaspora-x.com/public/icons/user.png"
    
this.User = User

class UserCollection extends Backbone.Collection
  model: User
  
  localStorage: new Store("UserCollection")

  smartFilter : (func) ->
    collection = new Backbone.Collection
    collection.model = @model
    collection.refresh(@select(func))
    @bind 'all', =>
      collection.refresh(@select(func))
    collection
    
  # Returns a list of users that I am subscribed to
  findFriends : ->
    @smartFilter (user) ->
      user.getChannel().isSubscribed()
    
  findByJid : (jid) ->
    @find (user) ->
      user.get('jid') == jid
      
  findOrCreateByJid : (jid) ->
    user = null

    if @findByJid(jid)
      user = @findByJid(jid)
    else
      user = new User {
        jid : jid
      }
      @add user
      # user.save()

    user
  # comparator: (post) ->
  #   post.get('published')
  
this.Users = new UserCollection
# this.Users.fetch()