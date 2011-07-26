{ AuthenticationView } = require 'views/authentication/skeleton'

class exports.RegisterView extends AuthenticationView
    cssclass: 'registerPicked'
    initialize: ->
        @el = $('#register')
        @el.find('.register.button').live 'click', =>
            # the form sumbit will always trigger a new connection
            name = $('#home_register_name').val()
            password = $('#home_register_pwd').val()
            if name.length and password.length
                @start_registration(name, password)
                # disable the form
                $('#home_register_submit').attr "disabled", "disabled"
                $('#register_waiting').css "visibility","visible"
        super

    start_registration: (name, password) ->
        @unbind 'hide', @hide
        @bind 'hide', @go_away
        app.handler.connection.register(name, password)
        app.handler.connection.bind "registered", @register_success
        app.handler.connection.bind "connected",  @login_success
        # TODO: find out which is the correct fail callback and remove it on success
        app.handler.connection.bind "regifail", @error
        app.handler.connection.bind "authfail", @error
        app.handler.connection.bind "sbmtfail", =>
            if app.handler.connection.isRegistered()
                @register_success()
            else
                @error()

    register_success: =>
        $('#register_waiting').html $('#login_waiting').html()

    login_success: =>
        $('#home_register_submit').removeAttr "disabled"
        $('#register_waiting').css "visibility","hidden"
