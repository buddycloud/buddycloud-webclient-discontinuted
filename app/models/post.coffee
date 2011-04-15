class Post extends Backbone.Model
  initializer: ->
    # ...

  serviceProvider: ->
    "pubsub-bridge@broadcaster.buddycloud.com"

  isReply: ->
    (@get('in_reply_to') != undefined) and (!isNaN(@get('in_reply_to')))
    
  hasGeoloc: ->
    (typeof @get('geoloc_text') == 'string') and (@get('geoloc_text') != "")

  isUserChannel: ->
    @get('channel').match /^.user/
    
  hasReplies: ->
    @getReplies().any()
    
  getReplies: ->
    _ @collection.filter( (post) =>
      post.get('in_reply_to') == @id
    )
    
  valid: ->
    @_validate(@attributes) == true
    
  _validate: (attributes) ->
    if (typeof attributes.content != 'string') or (attributes.content == "")
      "Can't have empty content"
    else
      true

  getAuthor: ->
    # if @get('author') instanceof User
    #   @get('author')
    # else
    Users.findOrCreateByJid @get('author')
    
  getAuthorName: ->
    @getAuthor().getName()

  getAuthorAvatar: ->
    @getAuthor().getAvatar()
    
  send: ->
    if @valid()
      @_send()
    else
      console.log "not sending.. seems invalid."
      
  _send: ->
    request = $iq({ "to" : @serviceProvider(), "type" : "set" })
      .c("pubsub", { "xmlns" : "http://jabber.org/protocol/pubsub" })
      .c("publish", {"node" : @get('channel')})
      .c("item")
      .c("entry", {"xmlns":"http://www.w3.org/2005/Atom"})
      .c("content", {"type" : "text"}).t(@get("content")).up()
      .c("author")
      .c("jid", {"xmlns":"http://buddycloud.com/atom-elements-0"}).t(@get("author")).up().up()

    if @isReply()
      request.c("in-reply-to", { "xmlns" : "http://purl.org/syndication/thread/1.0", "ref" : @get('in_reply_to') }).up()
      # ... geoloc ..

      # <link rel="license" type="text/html"
      #   href="http://creativecommons.org/licenses/by/2.5/" />      

    # Request..
    $c.c.sendIQ(request)
    #   (response) =>
    #     console.log 'response'
    #     console.log response
    #   (err) ->
    #     console.log 'error!'
    #     console.log err
    # )
    # 
    
  # 
  # validate: (attr) ->
  #   attr = _.extend(attr || {}, @attributes)
  #   
  #   if !attr.content
  #     'Post must have content'
  #   else
  #     true
    
Post.parseFromItem = (item) ->
  post = new Post { 
    id : parseInt(item.find('id').text().replace(/.+:/,''))
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

  post
  
this.Post = Post

class PostCollection extends Backbone.Collection
  model: Post

  comparator: (post) ->
    post.get('published')
    
  notReplies: ->
    @filter( (post) =>
      !post.get('in_reply_to')
    )

  parseResponse: (response) ->
    for item in $(response).find('item')
      post = Post.parseFromItem($(item))
      
      if (@get(post.id)) || (!post.valid())
        continue

      @add post
      post.save()
  
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
this.Posts = new PostCollection