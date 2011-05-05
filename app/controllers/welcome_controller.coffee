class WelcomeController extends Backbone.Controller
  routes :
    "" : "index"
    "logout" : "logout"

  logout: ->
    app.signout()
    
  index: ->
    app.focusTab('Home')

    $("#spinner").remove()

    if app.currentUser
      user = app.currentUser
      new UsersShowView { el : $("#content"), model : app.currentUser }
    else
      new WelcomeHomeView
      new CommonLoginView
    
    
    
new WelcomeController
