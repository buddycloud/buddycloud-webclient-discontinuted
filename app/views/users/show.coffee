class UsersShowView extends Backbone.View
  initialize: ->
    new CommonPageView

    @el = $("#main") # app.activePage()

    @collection = @model.getChannel().getPosts()
    
    @template = _.template('''
      <h1 class="channel-name">
        <%= user.getFullName() %>
      </h1>
      <% if(user.hasNoChannel()){ %>
        <p class="usermeta">
          <img src="public/icons/flag.png" /> <%= user.getFullName() %> hasn't signed up yet.
        </p>
      <% } else if (channel.isWhitelisted()) { %>
        <p class="usermeta">
          <img src="public/icons/users.png" /> <%= user.getFullName() %> only shares with friends.
        </p>
      <% } else if (channel.hasMetaData()){ %>
        <p class="usermeta">
          <img src="public/icons/globe_2.png" /> <%= user.get('jid') %>
          <img src="public/icons/clock.png" /> Created <%= channel.escapeCreationDate() %>
          <img src="public/icons/chart_bar.png" /> <%= channel.escape('num_subscribers') %> subscribers
          |
          <% if(user.getChannel().isSubscribed()){ %>
            <a href="#users/<%= user.get('jid') %>/unsubscribe">Unfriend</a>
          <% }else{ %>
            <a href="#users/<%= user.get('jid') %>/subscribe">Add as a friend</a>
          <% } %>
        </p>
        <p class="description">
          <%= channel.escape('description') %>
        </p>
      <% } else { %>
        <p class="usermeta">
          <img src="public/icons/sand.png" />Loading...
        </p>
      <% } %>

      <% if(user.hasNoChannel()){ %>

      <div class="big-notice">
        <h4>
          <img src="public/icons/flag.png" class="big-icon" />
          <%= user.getName().capitalize() %> hasn't signed up yet.
        </h4>
      
        <p>
          We couldn't find a channel for <%= user.getName().capitalize() %>, which means
          they haven't signed up yet. You can send an invitation to <%= user.getName().capitalize() %>
          and we will add them to your friends list when they sign up.
        </p>
      
        <button>
          Send invitation to <%= user.getName().capitalize() %>
        </button>
      </div>

      <% } else if (channel.isWhitelisted()) { %>

        <div class="big-notice">
          <h4>
            <img src="public/icons/users.png" class="big-icon" />
            <%= user.getName().capitalize() %> only shares with friends.
          </h4>
      
          <p>
            <%= user.getName().capitalize() %> has configured their privacy settings so that
            only friends can view or post on their wall. You can add <%= user.getName().capitalize() %>
            as a friend. Once <%= user.getName().capitalize() %> has confirmed your friendship, you
            will be able to see their posts.
          </p>
      
          <button>
            Add <%= user.getName().capitalize() %> as a friend
          </button>
        </div>

      <% } else { %>
        <% if ((channel.hasMetaData()) && (channel.canPost())) { %>
          <form action="#" class="new_activity status">
            <h4>Write on <%= user.getName() %>s wall</h4>
            <textarea cols="40" id="activity_content" name="content" rows="20"></textarea>
            <input name="commit" type="submit" value="Share" />
          </form>
        <% } %>
        
        <div class="posts"></div>
      <% } %>
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
    @el.html(@template( { view : this, user : @model, channel : @model.getChannel() })).find('.timeago').timeago()
    @delegateEvents()

    new PostsListView { el : @el.find('.posts'), model : @model.getChannel() }

    # Select the friends tab
    $("#main-tabs li").removeClass('active')
    $("#main-tabs li:nth-child(3)").addClass('active')
    

@UsersShowView = UsersShowView