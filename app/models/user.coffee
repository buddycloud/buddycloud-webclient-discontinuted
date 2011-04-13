class User extends Backbone.Model
  initializer: ->
    # ...

  fetchPosts: ->
    if $c.connected
      $c.getChannel @getNode()
    else
      # queue..?
    
  getName: ->
    @get('jid').toString().replace /@.+/, ''

  getStatus: ->
    (@get('status') + "").replace(/<.+?>/g,'')
    
  getNode: ->
    "/user/#{@get('jid')}/channel"
    
  subscribe: ->
    if $c.connected
      $c.subscribeToUser @get('jid')

  unsubscribe: ->
    if $c.connected
      $c.unsubscribeFromUser @get('jid')
  
  grantChannelPermissions: ->
    if $c.connected
      $c.grantChannelPermissions @get('jid'), @getNode()

  addFriend: (jid) ->
    if ! @get('friends')
      @set { friends : [] }

    for j in @get('friends') when jid == j
      # already exists...
      return
      
    @attributes.friends.push jid
    
  # more like the roster...
  getFriends: ->
    if ! @get('friends')
      @set { friends : [] }

    for jid in @get('friends')
      Users.findOrCreateByJid jid
    
  getAvatar: ->
    if @get('jid').toString().match /@buddycloud/
      "http://media.buddycloud.com/channel/54x54/buddycloud.com/#{@getName()}.png"
    else
      "http://www.gravatar.com/avatar/#{hex_md5(@get('jid'))}?d=http://media.buddycloud.com/channel/54x54/buddycloud.com/welcome.bot.png"
    
this.User = User

class UserCollection extends Backbone.Collection
  model: User
  
  localStorage: new Store("UserCollection")

  findByJid : (jid) ->
    @find (user) ->
      user.get('jid') == jid
      
  findOrCreateByJid : (jid) ->
    user  = null
    
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