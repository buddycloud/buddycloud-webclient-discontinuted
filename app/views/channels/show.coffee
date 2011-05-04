class ChannelsShowView extends Backbone.View
  initialize: ->
    new CommonPageView

    @el = $("#main")

    # Get some meta data (subscribers / etc...)
    @model.fetchMetadata()
    
    # Get the posts (collection may be empty initially)
    @collection = @model.getPosts()
    
    @template = _.template('''
      <div class="channel-info">
      </div>
      
        <p class="subscribe-buttons">
          <% if(channel.isSubscribed()){ %>
            <button class="unsubscribe">Unsubscribe</button>
          <% }else{ %>
            <button class="subscribe">Subscribe</button>
          <% } %>
        </p>
      
        <h1 class="channel-name">
          <%= channel.getName().capitalize() %>
        </h1>
        <p class="usermeta">
          <% if(channel.hasMetaData()){ %>
            <img src="public/icons/user.png" /> Owned by <%= channel.escapeOwnerNode() %>
            <img src="public/icons/clock.png" /> Created <%= channel.escapeCreationDate() %>
            <img src="public/icons/chart_bar.png" /> <%= channel.escape('num_subscribers') %> subscribers 
            <img src="public/icons/net_comp.png" /> Hosted by <%= channel.pubsubServiceDomain() %>
          <% } else { %>
            <img src="public/icons/sand.png" />Loading...
          <% } %>
        </p>
        <p class="description">
          <%= channel.escape('description') %>
        </p>
      </div>
      
      <% if(channel.canPost()){ %>
        <form action="#" class="new_activity status">
          <h4>New post</h4>
          <textarea cols="40" id="activity_content" name="content" rows="20"></textarea>
          <input name="commit" type="submit" value="Share" />
        </form>
      <% } %>
        
      <div class="posts"></div>
    ''')

    @model.bind 'change', @render
    
    @render()
  
  events: {
    'submit form.new_activity.status' : 'submit'
    'keydown textarea' : 'keydown'
    'click button.unsubscribe' : 'unsubscribe'
    'click button.subscribe' : 'subscribe'
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
  
  subscribe: (e) =>
    e.preventDefault()
    @model.subscribe()
    
  unsubscribe: (e) =>
    e.preventDefault()
    @model.unsubscribe()

  render: =>
    @el.html(@template( { channel : @model }))
    @delegateEvents()

    new PostsListView { el : @el.find('.posts'), model : @model }
    
    # Focus the second tab
    $("#main-tabs li").removeClass('active')
    $("#main-tabs li:nth-child(2)").addClass('active')
    

@ChannelsShowView = ChannelsShowView