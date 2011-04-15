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
    
new WelcomeController
