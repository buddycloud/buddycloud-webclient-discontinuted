window.app = {}
app.controllers = {}
app.models = {}
app.collections = {}
app.views = {}

MainController = require('controllers/main_controller').MainController
ConnectionHandler = require('handlers/connection_handler').ConnectionHandler
# models
User = require('models/user').User
LoginView = require('views/login/show').LoginView
HomeView = require('views/home/index').HomeView

# app bootstrapping on document ready
$(document).ready ->

  ### could be used to switch console output ###
  app.debug_mode = true
  app.debug = () ->
    console.log "DEBUG:", arguments if app.debug_mode
  Strophe.log = (level, msg) ->
    console.log "STROPHE:", level, msg if app.debug_mode and level > 0

  app.initialize = ->
    # current user
    app.current_user = new User()
    
    # add a new Connection Handler
    app.connection_handler = new ConnectionHandler()
    
    # initialize the user menu
    login = new LoginView()
    
    ### the password hack ###
    ###
    Normally a webserver would return user information for a current session. But there is no such thing in buddycloud.
    To achieve an auto-login we do a little trick here. Once a user has signed in, his browser asks him to store 
    the password for him. If the user accepts that, the login form will get filled automatically the next time he signs in.
    So when something is typed into the form on document ready we know that it must be the stored password and can just submit the form.
    ###
    el = $('#home_login_pwd')
    pw = el.val()
    unless pw.length > 0
      # the home view sould display some additional info in the future
      #app.views.home = new HomeView()
    else
      # prefilled password detected, sign in the user automatically
      $('#login_form').trigger "submit"
    login.show()
  
  
  app.initialize()
  
  # bootstrapping after login
  app.connection_handler.bind "connected", ->
    app.controllers.main = new MainController()
    
    Backbone.history.start()