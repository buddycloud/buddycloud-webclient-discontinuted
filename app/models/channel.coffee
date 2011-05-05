class Channel extends Backbone.Model
  initialize: ->
    @posts = PostCollection.forChannel(this)
    @set { new_posts : 0 }
    @status = null

    @bind 'add', =>
      @_incrementNewPosts()

  connector: ->
    @_connector ||= new Connector($c.c)
    
  markAllAsRead: ->
    @set { new_posts : 0 }

  _incrementNewPosts: ->
    @set { new_posts : @getNewPosts() + 1 }
    
  hasNewPosts: ->
    @getNewPosts() > 0

  getNewPosts: ->
    if @get('new_posts')
      parseInt @get('new_posts')
    else
      0
    
  getStatus: ->
    new String(@status)
    
  isLoading: ->
    (@status == null) || (@status == 'loading')
    
  updateUsers: ->
    if @isUserChannel()
      Users.findOrCreateByJid @getUserJid()
    
  # The node id of this chanel
  getNode: ->
    @get('node')
    
  subscribe: ->
    @connector().subscribe(channel, app.currentUser)
    channel.set { subscription : 'subscribed' }

  subscribe: ->
    @connector().unsubscribe(channel, app.currentUser)
    channel.set { subscription : null }
    
  isSubscribed: ->
    @get('subscription') == 'subscribed'
    
  isWhitelisted: ->
    @get('access_model') == 'whitelist'
    
  canView: ->
    @get('access_model') == 'open'
    
  canPost: ->
    (@get('affiliation') == 'owner') || (@get('affiliation') == 'publisher') || (@get('default_affiliation') == 'publisher')

  # Isn't a user node
  isStandalone: ->
    @getNode().match(/^.channel/)

  isUserChannel: ->
    @getNode().match(/^.user/)
    
  getUserJid: ->
    @getNode().match(/user.(.+?)\//)[1]
    
  escapeCreationDate: ->
    @escape('creation_date').replace(/T.+/,'')
    
  hasMetaData: ->
    !!@get('owner')
    
  escapeOwnerNode: ->
    @escape('owner').replace(/@.+/,'')
    
  fetchPosts: ->
    @status = 'loading'

    if $c.connected
      @_fetchPosts()
    else
      $c.bind 'connected', @_fetchPosts

  _fetchPosts: =>
    @connector().getChannelPosts(
      this, 
      (posts) =>
        for post in posts
          if p = @posts.get(post.id)
            p.set(post)
            p.save()
          else
            p = new Post(post)
            @posts.add(p)
            p.save()
      (errCode) =>
        @status = errCode
        @trigger 'change'
    )
    
  fetchMetadata: ->
    @connector().getMetadata(
      this,
      (obj) =>
        @set obj
        @save()
      (errCode) =>
        @set { status : errCode }
        @save()
    )
    
  getPosts: ->
    @fetchPosts()
    @posts

  getName: ->
    @get('node').replace(/.+\//,'')
    
this.Channel = Channel

