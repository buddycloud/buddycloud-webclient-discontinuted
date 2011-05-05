class WelcomeIndexView extends Backbone.View
  initialize: ->
    @render()
    
  render: ->
    @el.html($templates.welcomeIndex { user : app.currentUser })
    
    # @_renderSidebar()
    @_renderPosts()
    
  _renderSidebar: ->
    @el.find('.sidebar').html($templates.welcome_sidebar { 
      posts : Posts
      user : app.currentUser
      friends : Friends 
    })
    
  _renderPosts: ->
    new PostsListView { el : @el.find('.posts'), collection : Posts }
    # @el.tml
    #  posts : Posts, )

@WelcomeIndexView = WelcomeIndexView
