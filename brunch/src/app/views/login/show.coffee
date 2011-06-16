ConnectionHandler = require('handlers/connection_handler').ConnectionHandler

class exports.LoginView extends Backbone.View
  template : require 'templates/login/show'
  
  initialize : ->
    that = this
    $('#login_form').submit (ev) ->
      ev.preventDefault()
      ev.stopPropagation()
      
      # the form sumbit will alwasy trigger a new connection
      that.start_connection()

      #$(this).hide()
      $('#home_login_submit').attr "disabled", "disabled"
      # TODO: show nicer spin
      #$(this).after '<img class="loading" src="/public/spinner2.gif" />'
      return false
  
  show : ->
    $('#login_form').delay(50).fadeIn()
  
  start_connection : =>
    app.connection_handler = new ConnectionHandler()
    # pretend we get an connection immediately
    app.connection_handler.connect "xxx", "xxx"
    app.connection_handler.bind "connected", @go_away
    app.connection_handler.bind "connfail", @sign_in_error
    app.connection_handler.bind "disconnected", @sign_in_error
  
  go_away : =>
    # nicely animate the login form away
    el = $('#login')
    curr_pos = el.position()
    $('#login').css(
      "top" : "#{curr_pos.top}px"
      "left": "#{curr_pos.left}px"
    ).animate({"top" : "#{curr_pos.top + 50}px"}, 200).animate("top" : "-800px")
    
  sign_in_error : =>
    # first wobble animation try
    el = $('#login')
    curr_pos = el.position()
    $('#login').css(
      "top" : "#{curr_pos.top}px"
      "left": "#{curr_pos.left}px"
    ).animate({"left":"#{curr_pos.left + 10}"},50)
    .animate({"left":"#{curr_pos.left - 10}"},50)
    .animate({"left":"#{curr_pos.left + 10}"},50)
    .animate({"left":"#{curr_pos.left - 10}"},50, ->
      alert "Wrong credentials!"
    )