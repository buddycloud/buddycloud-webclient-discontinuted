class PostCollection extends Backbone.Collection
  model: Post
  localStorage : new Store("PostCollection")
    
  comparator: (post) ->
    post.get('published')
    
  notReplies: ->
    @filter( (post) =>
      !post.get('in_reply_to')
    )
    
  getPosts: ->
    this

# Todo - refactor me - this should be a hasMany or something....
PostCollection.forChannel = (model) ->
  unique = "channel-#{model.getNode()}"

  collection = new PostCollection
  collection.localStorage = new Store("PostCollection-#{unique}")
  collection.fetch()
  collection

PostCollection.forUser = (model) ->
  unique = "user-#{model.getNode()}"

  collection = new PostCollection
  collection.localStorage = new Store("PostCollection-#{unique}")
  collection.fetch()
  collection
  
this.PostCollection = PostCollection