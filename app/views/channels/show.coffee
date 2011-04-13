class ChannelsShowView extends Backbone.View
  initialize: ->
    new CommonPageView

    @el = $("#main")

    # Get some meta data (subscribers / etc...)
    @model.fetchMetadata()
    
    # Get the posts (collection may be empty initially)
    @collection = new PostCollection # @model.getPosts()
    
    @template = _.template('''

      <h1 class="channel-name">
        <%= channel.getName().capitalize() %>
      </h1>
      <p class="usermeta">
        <% if(channel.hasMetaData()){ %>
          <img src="public/icons/user.png" /> Owned by <%= channel.escapeOwnerNode() %>
          <img src="public/icons/clock.png" /> Created <%= channel.escapeCreationDate() %>
          <img src="public/icons/chart_bar.png" /> <%= channel.escape('num_subscribers') %> subscribers 
          <!--img src="public/icons/cert.png" /> Ranked #<%= channel.escape('popularity') %> in popularity -->
        <% } else { %>
          <img src="public/icons/sand.png" />Loading...
        <% } %>
      </p>
      <p class="description">
        <%= channel.escape('description') %>
      </p>
    
      <form action="#" class="new_activity status">
        <h4>New post</h4>
        <textarea cols="40" id="activity_content" name="content" rows="20"></textarea>
        <input name="commit" type="submit" value="Share" />
      </form>
        
      <div class="posts"></div>
    ''')

    @model.bind 'change', @render
    
    @render()
  
  events: {
    'submit form.new_activity.status' : 'submit'
    'keydown textarea' : 'keydown'
  }
  
  keydown: (e) ->
    if ((e.metaKey || e.shiftKey) && e.keyCode == 13)
      $(e.currentTarget).parents("form").submit();
      e.preventDefault();
    
  submit: (e) ->
    e.preventDefault()

    post = new Post {
      content : @el.find('textarea:first').val()
      in_reply_to : null
      channel : @model.getNode()
      author : app.currentUser.get('jid')
    }
    
    post.send()
  
  render: =>
    if @renderTimeout
      clearTimeout @renderTimeout
      
    @renderTimeout = setTimeout( =>
      @el.html(@template( { channel : @model }))
      @delegateEvents()

      new PostsListView { el : @el.find('.posts'), collection : @collection }
      
      @renderTimeout = null
    , 50)

@ChannelsShowView = ChannelsShowView