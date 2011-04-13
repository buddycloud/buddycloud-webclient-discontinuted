class Channel extends Backbone.Model
  initialize: ->
    # ...
    @conn = $c.c
    @posts = new PostCollection
    
  # The node id of this chanel
  getNode: ->
    @get('node')
    
  serviceProvider: ->
    "pubsub-bridge@broadcaster.buddycloud.com"

  escapeCreationDate: ->
    @escape('creation_date').replace(/T.+/,'')
    
  hasMetaData: ->
    !!@get('owner')
    
  escapeOwnerNode: ->
    @escape('owner').replace(/@.+/,'')
    
  fetchPosts: ->
    request = $iq({ "to" : @serviceProvider(), "type" : "get"})
      .c("pubsub", {"xmlns":"http://jabber.org/protocol/pubsub"})
      .c("items", {"node":@getNode()})
      # .c("set", {"xmlns":"http://jabber.org/protocol/rsm"})
      # .c("after").t("100")
    
    @conn.sendIQ(
      request,
      (response) =>
        for item in $(response).find('item')
          post = Post.parseFromItem($(item))
          
          if (@posts.get(post.id)) || (true != post.validate())
            continue

          @posts.add post
          post.save()

        # ...
      (err) =>
        console.log 'err'
        console.log err
        # ...
    )
    
  fetchMetadata: ->
    request = $iq( { "to" : @serviceProvider(), "type" : "get" })
      .c( "query", { "xmlns" : "http://jabber.org/protocol/disco#info", "node" : @getNode() })

    @conn.sendIQ(
      request,
      (response) =>
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


    $c.getMetaData this
    
  getPosts: ->
    @fetchPosts()
    @posts
    
    # 
    # @posts = Posts.select((post) =>
    #   (!post.isReply()) && (post.get('channel') == @model.getNode())
    # ).reverse()

  getName: ->
    @get('node').replace(/.+\//,'')
    
this.Channel = Channel

class ChannelCollection extends Backbone.Collection
  model: Channel
  
  localStorage: new Store("ChannelCollection")
  
  findByNode : (node) ->
    @find (channel) ->
      channel.get('node') == node
      
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
  
this.Channels = new ChannelCollection
this.Channels.refresh()