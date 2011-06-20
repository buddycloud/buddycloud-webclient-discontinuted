ConnectionHandler = require('handlers/connection_handler').ConnectionHandler

class exports.LoginView extends Backbone.View
  template : require 'templates/login/show'
  
  initialize : ->
    $('#login_form').submit (ev) =>
      ev.preventDefault()
      ev.stopPropagation()
      
      # the form sumbit will alwasy trigger a new connection
      @start_connection()

      # disable the form
      $('#home_login_submit').attr "disabled", "disabled"
      $('#login_waiting').css "visibility","visible"
      # TODO: show nicer spin
      #$(this).after '<img class="loading" src="/public/spinner2.gif" />'
      return false
  
  show : ->
    $('#login_form').delay(50).fadeIn()
  
  start_connection : =>
    app.connection_handler = new ConnectionHandler()
    # pretend we get an connection immediately
    app.connection_handler.connect "xxx", "xxx"
    app.connection_handler.bind "connected", @sign_in_success
    app.connection_handler.bind "connfail", @sign_in_error
    app.connection_handler.bind "disconnected", @sign_in_error
  
  sign_in_success : =>
    $('#home_login_submit').removeAttr "disabled"
    $('#login_waiting').css "visibility","hidden"
    @go_away()
  
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