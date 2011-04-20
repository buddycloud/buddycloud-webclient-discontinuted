class PostsListView extends Backbone.View
  initialize: ->
    @template = _.template('''
        <div class="activity" data-id="<%= post.id %>">
          <div class="grid_1">
            <img class="thumb avatar" src="<%= post.getAuthorAvatar() %>" />
          </div>
          <div class="grid_4">
            <h4>
              <a href="#users/<%= post.getAuthor().get('jid') %>"><%= post.getAuthorName() %> </a>
            </h4>
            <p class="content">
              <%= view.formatContent(post) %>
            </p>
            <p class="meta">
              <span class='timeago' title='<%= post.get('published') %>'><%= post.get('published') %></span>
              <% if (model.canPost()){ %>
                | <a href="#" onclick="$(this).parents('.activity').find('form').show().find('textarea').focus(); return false">Comment</a>
              <% } %>
              <% if(post.hasGeoloc()){ %>
                | <%= post.get('geoloc_text') %>
              <% } %>
            </p>
          
            <div class="comments">
              <div class="chevron">&diams;</div>
            </div>

            <form class="new_activity reply" action="#">
              <input type="hidden" name="in_reply_to" value="<%= post.id %>" />
              <textarea name="content"></textarea>
              <input type="submit" value="Comment" />
            </form>

          </div>
          <div class="clear"></div>
        </div>
    ''')
    
    @collection = @model.getPosts()

    @collection.bind 'add', @addPost
    @collection.bind 'change', @updatePost
    @collection.bind 'remove', @removePost
    @collection.bind 'refresh', @render

    @render()
  
  events: {
    'submit form' : 'submit'
    'keydown textarea' : 'keydown'
  }
  
  formatContent: (post) ->
    content = post.escape('content')
    
    # Format hash channels
    content = content.replace /\#\S+?\b/, (match) ->
      channel = match.slice(1,100)
      "<a class='inline-channel' href='#channels/#{channel}'>##{channel}</a>"

    # Format email addresses
    content = content.replace /\b\S+?@\S+\.\S+?\b/, (match) ->
      jid = new Jid(match)

      # If it's a known buddycloud provider - then change it to a user link
      if jid.buddycloudDomain()
        "<a class='inline-jid' href='#users/#{jid.getNode()}'>#{jid.getNode()}</a>"
      else
        # Otherwise just link the email address
        "<a class='inline-email' href='mailto:#{match}'>#{match}</a>"
          
    # Format external links
    content = content.replace /\bhttp:\/\/\S+\b/, (match) ->
      truncated = if match.length < 35
        match
      else
        match.slice(7,27) + "..." + match.slice(-10, match.length)
        
      "<a class='inline-link' href='#{match}'>#{truncated}</a>"

  keydown: (e) =>
    if e.keyCode == 13
      if (e.metaKey || e.shiftKey)
        # ...
      else
        $(e.currentTarget).parents("form").submit();
        e.preventDefault();
    
  submit: (e) ->
    e.preventDefault()
    form = $(e.currentTarget)

    post = new Post {
      content : form.find('textarea:first').val()
      in_reply_to : form.find("input[name='in_reply_to']").val()
      channel : @model.getNode()
      author : app.currentUser.get('jid')
    }

    # Hide the form
    form.find('textarea:first').val('')
    form.hide()
    post.send()

  addPost: (post) =>
    if post.isReply()
      div = @el.find("div[data-id='#{post.get('in_reply_to')}']")
      @addReply(div, post)
      div.find('.comments').show()
    else
      div = $(@template( { model : @model, view : this, post : post }))
      div.find('.timeago').timeago()
      div.insertBefore @el.find("div:first")
      div.find('a.inline-link').embedly { method : 'afterParent', maxWidth : 400 }
    
      if post.hasReplies()
        div.find('.comments').show()
      else
        div.find('.comments').hide()
        
      for reply in post.getReplies().value()
        @addReply(div, reply)
        
  addReply: (div, reply) ->
    el = $("<div />")
    el.appendTo(div.find('.comments'))
    new PostsCommentsView { model : reply, el : el }

  removePost: (post) =>
    console.log "posts#list#removePost not implemented!"
    
  updatePost: (post) =>
    console.log "posts#list#removePost not implemented!"

  render: =>
    @el.html("<div />")
    
    for post in @collection.notReplies()
      @addPost post
      
    @delegateEvents()

@PostsListView = PostsListView