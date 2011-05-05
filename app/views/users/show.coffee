class UsersShowView extends Backbone.View
  initialize: ->
    # new CommonPageView
    # @el = $("#main") # app.activePage()
    
    @collection = @model.getChannel().getPosts()
    

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
    @el.html($templates.usersShow { view : this, user : @model, channel : @model.getChannel() }).find('.timeago').timeago()
    @delegateEvents()

    new PostsListView { el : @el.find('.posts'), model : @model.getChannel() }
    

@UsersShowView = UsersShowView