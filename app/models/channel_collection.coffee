class ChannelCollection extends Backbone.Collection
  model: Channel
  
  initialize: ->
    @localStorage = new Store("ChannelCollection")
  
  findByNode : (node) ->
    @find (channel) ->
      channel.get('node') == node
      
  getStandalone: ->
    channels = new ChannelCollection

    channels.refresh(@select (channel) ->
      (channel.isStandalone()) && (channel.isSubscribed())
    )

    channels
    
  sortByNewPosts : ->
    @comparator = (c) ->
      0 - c.getNewPosts()
    @sort { silent : true }
    this
    
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

this.ChannelCollection = ChannelCollection