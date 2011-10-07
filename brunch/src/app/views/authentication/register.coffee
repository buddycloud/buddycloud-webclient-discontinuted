{ AuthenticationView } = require 'views/authentication/base'
{ EventHandler } = require 'util'


class exports.RegisterView extends AuthenticationView
    cssclass: 'registerPicked'
    initialize: ->
        @el = $('#register')

        passwd = $('#home_register_new_password')
        confirm = $('#home_register_new_confirm')
        confirm.keyup =>
            if passwd.val() is confirm.val()
                unless confirm.hasClass 'match'
                    confirm.removeClass 'missmatch'
                    confirm.addClass 'match'
            else
                unless confirm.hasClass 'missmatch'
                    confirm.removeClass 'match'
                    confirm.addClass 'missmatch'


        $('#home_register_new_jid').autoSuggestion
            suffix: (val) ->
                if val is "" or val.indexOf("@") isnt -1
                    ""
                else
                    "@#{config.domain}"

        @el.find('#home_register_account').live 'click', EventHandler (ev) =>
            ev.stopPropagation()
            # the form sumbit will always trigger a new connection
            name = $('#home_register_new_jid').val()
            password = $('#home_register_new_password').val()
            email = $('#home_register_new_email').val()
            email = undefined unless email.length
            if name.length and password.length
                unless confirm.val() is passwd.val()
                    alert "password missmatch!" # FIXME
                    return false
                @start_registration(name, password, email)
                # disable the form
                $('#home_register_submit').prop "disabled", yes
                $('#register_waiting').css "visibility","visible"
            else
                alert "no name!" unless name.length # FIXME
                alert "no password!" unless password.length # FIXME
        super

    start_registration: (name, password, email) ->
        @unbind 'hide', @hide
        @bind 'hide', @go_away
        app.handler.connection.register name, password, email
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
