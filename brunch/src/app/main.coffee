window.app = {}
app.controllers = {}
app.models = {}
app.collections = {}
app.views = {}

MainController = require('controllers/main_controller').MainController
User = require('models/user').User
UserMenu = require('views/shared/user_menu').UserMenu
HomeView = require('views/home/index').HomeView

# app bootstrapping on document ready
$(document).ready ->
  app.initialize = ->
  
    # current user
    app.current_user = new User()
    
    # initialize the user menu
    user_menu = new UserMenu()
    
    ### the password hack ###
    el = $('#home_login_pwd')
    pw = el.val()
    unless pw.length > 0
      #alert "TODO: display login form and some home information"
      app.controllers.main = new MainController()
      user_menu.show_login()
      app.views.home = new HomeView()
    else
      #alert "Your password is: #{pw} ! Logging you in now!"
      $('#login_form').trigger "submit"
    
  app.initialize()
  Backbone.history.start()
