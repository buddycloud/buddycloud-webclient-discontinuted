class PostsCommentsView extends Backbone.View
  initialize: ->
    @template = _.template('''
      <div class="comment">
        <img class="micro avatar" src="<%= reply.getAuthorAvatar() %>" />
        <p class="content">
          <a href="#users/<%= reply.getAuthor().get('jid') %>"><%= reply.getAuthorName() %></a> 
          <%= view.formatContent(reply) %>
        </p>
        <span class="meta">
          <span class='timeago' title='<%= reply.get('published') %>'><%= reply.get('published') %></span>
          <% if(reply.hasGeoloc()){ %>
            | <%= reply.get('geoloc_text') %>
          <% } %>
        </span>
      </div>
    ''')

    @model.bind 'change', @render

    @render()
  
  # events: {
  #   'submit form' : 'submit'
  #   'keydown textarea' : 'keydown'
  # }
  
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
    content = content.replace /\bhttp:\/\/\S+/, (match) ->
      truncated = if match.length < 35
        match
      else
        match.slice(7,27) + "..." + match.slice(-10, match.length)
        
      "<a class='inline-link' href='#{match}'>#{truncated}</a>"

  render: =>
    @el.html(@template( { reply : @model, view : this }))
    @delegateEvents()

@PostsCommentsView = PostsCommentsView
