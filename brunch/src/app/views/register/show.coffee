class exports.RegisterView extends Backbone.View
  template : require 'templates/register/show'

  initialize : ->
    $('#register').html @template()
    $('#register_form').submit (ev) =>
      ev.preventDefault()
      ev.stopPropagation()

      # the form sumbit will always trigger a new connection
      name = $('#home_register_name').val()
      password = $('#home_register_pwd').val()
      if name.length and password.length
        @start_registration(name, password)
        # disable the form
        $('#home_register_submit').attr "disabled", "disabled"
        $('#register_waiting').css "visibility","visible"

      return false

  show : ->
    $('#register').show()
    $('#register_form').delay(50).fadeIn()
    $('#login_form').fadeOut()

  start_registration : (name, password) =>
    app.connection_handler.register(name, password)
    app.connection_handler.bind "registered", @register_success
    app.connection_handler.bind "connected", @login_success
    # TODO: find out which is the correct fail callback and remove it on success
    app.connection_handler.bind "regifail", @register_error
    app.connection_handler.bind "authfail", @register_error
    app.connection_handler.bind "sbmtfail",  =>
      if app.connection_handler.isRegistered()
        @register_success()
      else
        @register_error.apply(arguments)

  register_success : =>
    $('#register_waiting').html $('#login_waiting').html()

  login_success : =>
    $('#home_register_submit').removeAttr "disabled"
    $('#register_waiting').css "visibility","hidden"
    @go_away()

  go_away : ->
    # nicely animate the register form away
    el = $('#register')
    curr_pos = el.position()
    $('#register').css(
      "top" : "#{curr_pos.top}px"
      "left": "#{curr_pos.left}px"
    ).animate({"top" : "#{curr_pos.top + 50}px"}, 200).animate("top" : "-800px")

  register_error : ->
    # first wobble animation try
    el = $('#register')
    curr_pos = el.position()
    $('#register').css(
      "top" : "#{curr_pos.top}px"
      "left": "#{curr_pos.left}px"
    ).animate({"left":"#{curr_pos.left + 10}"},50)
    .animate({"left":"#{curr_pos.left - 10}"},50)
    .animate({"left":"#{curr_pos.left + 10}"},50)
    .animate({"left":"#{curr_pos.left - 10}"},50, ->
      alert "Wrong credentials!"
    )