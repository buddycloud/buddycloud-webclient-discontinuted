{ AuthenticationView } = require 'views/authentication/skeleton'

class exports.LoginView extends AuthenticationView
    cssclass: 'loginPicked'
    initialize: ->
        @el = $('#login')
        @el.find('form').live 'submit', (ev) =>
            ev.preventDefault()
            ev.stopPropagation()
            # the form sumbit will always trigger a new connection
            jid = $('#home_login_jid').val()
            password = $('#home_login_pwd').val()
            if jid.length > 0 and password.length > 0
                @start_connection(jid, password)
                # disable the form and give feedback
                $('#home_login_submit')
                    .prop("disabled", yes)
                    .text "Logging in..."
            return false
        super

    start_connection: (jid, password) ->
        @unbind 'hide', @hide
        @bind 'hide', @go_away
        # pretend we get a connection immediately
        app.handler.connection.connect jid, password
        app.handler.connection.bind "connected", @success
        # TODO: find out which is the correct fail callback and remove it on success
        app.handler.connection.bind "connfail", @error
        app.handler.connection.bind "disconnected", @error

    success: =>
        $('#home_login_submit').prop "disabled", false
        $('#login_waiting').text "Logging in..."
