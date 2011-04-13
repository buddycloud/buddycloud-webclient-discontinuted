class Post extends Backbone.Model
  initializer: ->
    # ...

  isReply: ->
    (@get('in_reply_to') != undefined) and (!isNaN(@get('in_reply_to')))
    
  hasGeoloc: ->
    (typeof @get('geoloc_text') == 'string') and (@get('geoloc_text') != "")

  isUserChannel: ->
    @get('channel').match /^.user/
  hasReplies: ->
    @getReplies().any()
    
  getReplies: ->
    _ Posts.filter( (post) =>
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
    if @get('author') instanceof User
      @get('author')
    else
      Users.findOrCreateByJid @get('author')
    
  getAuthorName: ->
    @getAuthor().getName()

  getAuthorAvatar: ->
    @getAuthor().getAvatar()
    
  send: ->
    if @valid()
      $c.sendPost(this)
    else
      # console.log "not sending.. seems invalid."

  validate: (attr) ->
    attr ||= @attributes
    
    if !attr.content
      'Post must have content'
    else
      true
    
Post.parseFromItem = (item) ->
  post = new Post { 
    id : parseInt(item.find('id').text().replace(/.+:/,''))
    content : item.find('content').text() 
    author : Users.findOrCreateByJid(item.find('author jid').text())
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
  
this.PostCollection = PostCollection
this.Posts = new PostCollection