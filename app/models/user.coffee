class User extends Backbone.Model
  initialize: ->

  serviceProvider: ->
    "pubsub-bridge@broadcaster.buddycloud.com"

  getChannel: ->
    Channels.findOrCreateByNode @getNode()

  getNode: ->
    "/user/#{@get('jid')}/channel"
    
  getMood: ->
    @get('mood')
    
  notFound: ->
    if @getChannel().isLoading()
      false
    else
      @getChannel().getStatus().toString() != '200'
    
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
    
  fetchSubscriptions: () ->
    # <iq to='maitred.buddycloud.com' type='get' id='channels1'>
    #   <query xmlns='http://buddycloud.com/protocol/channels'>
    #     <items var='member' id='simon@buddycloud.com' />
    #   </query>
    # </iq>

    request = $iq({ to : @getChannel().getMaitred(), type : 'get' })
      .c('query', { xmlns : "http://buddycloud.com/protocol/channels" })
      .c('items', { 'var' : 'member', 'id' : @getJid() })
      
    # 
    # request = $iq({"to" : @getChannel().serviceProvider(), "type":"get"})
    #   .c("pubsub", {"xmlns":"http://jabber.org/protocol/pubsub"})
    #   .c("subscriptions", { jid : @getJid() })
  
    console.log Strophe.serialize(request)
    
    # Request..
    $c.c.sendIQ(
      request
      (response) ->
        console.log 'response'
        # console.log response
        console.log Strophe.serialize(response)
        
        channels = for item in $(response).find('item')
          Channels.findOrCreateByNode $(item).find('id').text()
          
        for c in channels
          console.log c.getNode()
          
        # console.log channels.pluck('node')
        
        # for s in $(response).find('subscription')
        #   console.log $(s).attr('node')

        # for s in $(response).find('subscription')
        #   console.log $(s).attr('node')
        # console.log response
      (err) ->
        console.log 'getSubscriptions#err'
        console.log err
    )
  
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
    
  findByGroup : (group) ->
    @smartFilter (user) ->
      user.get('group') == group
      
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
  
@UserCollection = UserCollection  
# this.Users.fetch()