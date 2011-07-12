ConnectionHandler = require('handlers/connection_handler').ConnectionHandler

class exports.LoginView extends Backbone.View
  template : require 'templates/login/show'
  
  initialize : ->
    $('#login_form').submit (ev) ->
      ev.preventDefault()
      ev.stopPropagation()
      
      # the form sumbit will alwasy trigger a new connection
      app.connection_handler = new ConnectionHandler()
      app.connection_handler.connect "xxx", "xxx"

      #app.current_user.log_in()
      $(this).hide()
      $(this).after '<img class="loading" src="/public/spinner2.gif" />'
      return false
  
  show : ->
    $('#login_form').delay(50).fadeIn()
  