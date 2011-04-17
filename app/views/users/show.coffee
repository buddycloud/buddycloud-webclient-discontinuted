class UsersShowView extends Backbone.View
  initialize: ->
    new CommonPageView

    @el = $("#main") # app.activePage()

    @collection = @model.getChannel().getPosts()
    
    @template = _.template('''
      <h1>
        <%= user.getName() %>
      </h1>
      <p class="usermeta">
        <img src="public/icons/globe_2.png" /> <%= user.get('jid') %>
        |
        <% if(user.getChannel().isSubscribed()){ %>
          <a href="#users/<%= user.get('jid') %>/unsubscribe">Unsubscribe</a>
        <% }else{ %>
          <a href="#users/<%= user.get('jid') %>/subscribe">Subscribe</a>
        <% } %>
      </p>
    
      <form action="#" class="new_activity status">
        <h4>Write on <%= user.getName() %>s wall</h4>
        <textarea cols="40" id="activity_content" name="content" rows="20"></textarea>
        <input name="commit" type="submit" value="Share" />
      </form>
        
      <div class="posts"></div>
    ''')

    @model.bind 'change', @render
    @model.getChannel().bind 'change', @render

    @render()
  
  events: {
    'submit form.new_activity.status' : 'submit'
    'keydown textarea' : 'keydown'
  }
  
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
      content : @el.find('textarea:first').val()
      in_reply_to : null
      channel : @model.getNode()
      author : app.currentUser.get('jid')
    }
    
    post.send()

    # Reset the form
    form.find('textarea:first').val('').blur()
  
  # getPosts: ->
  #   _ @collection.select((post) =>
  #     (!post.isReply()) && (post.get('channel') == @model.getNode())
  #   ).reverse()
  #   
  render: =>
    @el.html(@template( { view : this, user : @model })).find('.timeago').timeago()
    @delegateEvents()

    new PostsListView { el : @el.find('.posts'), model : @model.getChannel() }

@UsersShowView = UsersShowView