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
      new WelcomeIndexView { el : $("#content") }
    else
      new WelcomeHomeView { el : $("#content") }
    
    
    
new WelcomeController
