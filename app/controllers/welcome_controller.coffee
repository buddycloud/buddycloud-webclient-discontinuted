class WelcomeController extends Backbone.Controller
  routes :
    "" : "index"
    "logout" : "logout"

  logout: ->
    app.signout()
    
  index: ->
    $("#spinner").remove()

    if app.currentUser
      user = app.currentUser
      new UsersShowView { model : app.currentUser }

      # Focus the second tab
      $("#main-tabs li").removeClass('active')
      $("#main-tabs li:nth-child(1)").addClass('active')
    else
      new WelcomeHomeView
      new CommonLoginView
    
    
    
new WelcomeController
