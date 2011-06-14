###
Initial router when a user visits the index page
###
class WelcomeController extends Backbone.Controller
  routes :
    "" : "index"
    "logout" : "logout"

  logout: ->
    app.signout()
    
  index: ->
    app.focusTab('Home')
    $("#spinner").remove()

    # if a user is signed in navigate him to the index view,
    if app.currentUser
      user = app.currentUser
      new WelcomeIndexView { el : $("#content") }
    # else to the login view
    else
      new WelcomeHomeView { el : $("#content") }
    
    
    
new WelcomeController
