window.app = {}
app.controllers = {}
app.models = {}
app.collections = {}
app.views = {}
app.handlers = {}

{ MainController } = require('controllers/main_controller')
{ ConnectionHandler } = require('handlers/connection_handler')
# models
{ User } = require('models/user')
# views
{ RegisterView } = require('views/register/show')
{ LoginView } = require('views/login/show')
{ HomeView } = require('views/home/index')

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
    # TODO

    # initialize start view
    start_view = null
    start_view = new RegisterView() if window.location.hash is '#register'
    start_view or= new LoginView()

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
    start_view.show()


  app.initialize()

  # bootstrapping after login
  app.connection_handler.bind "connected", ->
    app.controllers.main = new MainController()

    Backbone.history.start()