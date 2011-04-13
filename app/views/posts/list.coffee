class PostsListView extends Backbone.View
  initialize: ->
    @template = _.template('''
        <div class="activity">
          <div class="grid_1">
            <img class="thumb avatar" src="<%= post.getAuthorAvatar() %>" />
          </div>
          <div class="grid_5">
            <h4>
              <a href="#users/<%= post.getAuthor().get('jid') %>"><%= post.getAuthorName() %> </a>
            </h4>
            <p class="content">
              <%= view.formatContent(post) %>
            </p>
            <p class="meta">
              <span class='timeago' title='<%= post.get('published') %>'><%= post.get('published') %></span> |
              <a href="#" onclick="$(this).parents('.activity').find('form').show().find('textarea').focus(); return false">Comment</a>
              <% if(post.hasGeoloc()){ %>
                | <%= post.get('geoloc_text') %>
              <% } %>
              | <%= post.id %>
            </p>
          
            <% if(post.hasReplies()){ %>
            
              <div class="comments">
                <div class="chevron">&diams;</div>

                <% post.getReplies().each(function(reply){ %>
                  <div class="comment">
                    <img class="micro avatar" src="<%= reply.getAuthorAvatar() %>" />
                    <p class="content">
                      <a href="#users/<%= reply.getAuthor().get('jid') %>"><%= reply.getAuthorName() %></a> 
                      <%= view.formatContent(reply) %>
                    </p>
                    <span class="meta">
                      <span class='timeago' title='<%= reply.get('published') %>'><%= post.get('published') %></span>
                      <% if(reply.hasGeoloc()){ %>
                        | <%= reply.get('geoloc_text') %>
                      <% } %>
                      | <%= reply.id %>
                    </span>
                  </div>
                <% }); %>
              
              </div>
            <% }; %>

            <form class="new_activity reply" action="#">
              <input type="hidden" name="in_reply_to" value="<%= post.id %>" />
              <textarea name="content"></textarea>
              <input type="submit" value="Comment" />
            </form>

          </div>
          <div class="clear"></div>
        </div>
    ''')

    @collection.bind 'add', @render
    @collection.bind 'change', @render
    @collection.bind 'remove', @render
    @collection.bind 'refresh', @render

    @render()
  
  events: {
    'submit form' : 'submit'
    'keydown textarea' : 'keydown'
  }
  
  formatContent: (post) ->
    post.escape('content').replace /\b\S+?@\S+\.\S+?\b/, (jid) ->
      node = jid.replace(/@.+/,'')
      "<a class='inline-jid' href='#users/#{jid}'>#{node}</a>"
      
  keydown: (e) ->
    if ((e.metaKey || e.shiftKey) && e.keyCode == 13)
      $(e.currentTarget).parents("form").submit();
      e.preventDefault();
    
  submit: (e) ->
    e.preventDefault()

    post = new Post {
      content : @el.find('textarea:first').val()
      in_reply_to : @el.find("input[name='in_reply_to']").val()
      channel : app.currentUser.getNode()
      author : app.currentUser.get('jid')
    }

    post.send()

  render: =>
    @el.html("<div />")
    
    for post in @collection.models
      div = $(@template( { view : this, post : post }))
      div.find('.timeago').timeago()
      div.insertBefore @el.find("div:first")
      
    @delegateEvents()

@PostsListView = PostsListView