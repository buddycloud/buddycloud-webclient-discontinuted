class WelcomeController extends Backbone.Controller
  routes :
    "" : "index"
    "home" : "home"
    
  index: ->
    if localStorage['jid'] && localStorage['password']
      app.connect()
    else
      window.location.hash = "login"
    
  home: ->
    $("#spinner").remove()

    user = app.currentUser
    # user.subscribe()
    # user.fetchPosts()
    new UsersShowView { model : user }
    
    # Focus the second tab
    $("#main-tabs li").removeClass('active')
    $("#main-tabs li:nth-child(1)").addClass('active')
    
    
new WelcomeController
