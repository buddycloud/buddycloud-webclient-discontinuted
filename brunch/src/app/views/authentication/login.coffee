{ AuthenticationView } = require 'views/authentication/base'
{ EventHandler, getBrowserPrefix } = require 'util'


class exports.LoginView extends AuthenticationView
    cssclass: 'loginPicked'
    initialize: ->
        @el = $('#login')
        input = $('#home_login_jid')
        input.autoSuggestion
            suffix: (val) ->
                if val is "" or val.indexOf("@") isnt -1
                    ""
                else
                    "@#{config.domain}"

        ##
        # webkit only saves input content when submit was successful
        # this includes a full pagereload, which is not suitable
        # firefox does it well and asks the user if he wants to save the passwd
        if getBrowserPrefix() is "-webkit-"
            $('#home_login_pwd').textSaver()
            # only track what is before the @
            userinput = input.parent().find('#auto-suggestion-'+input.prop 'id')
            userinput.textSaver()
            userinput.keyup() # update underlying inputfields

        @el.find('form').live 'submit', EventHandler (ev) =>
            ev.stopPropagation()
            # the form sumbit will always trigger a new connection
            jid = $('#home_login_jid').val()
            password = $('#home_login_pwd').val()
            if jid.length > 0 and password.length > 0
                @start_connection(jid, password)
                # disable the form and give feedback
                $('#home_login_submit').prop "disabled", yes
                @el.find('.leftBox').addClass "working"
        super

    start_connection: (jid, password) ->
        @unbind 'hide', @hide
        @bind 'hide', @go_away
        # pretend we get a connection immediately
        app.handler.connection.connect jid, password
        app.handler.connection.bind "connected", @reset
        # TODO: find out which is the correct fail callback and remove it on success

        ["authfail", "connfail", "disconnected"].forEach (type) =>
            event = () =>
                app.handler.connection.unbind type, event
                @reset()
                @error(type)
            app.handler.connection.bind type, event

    reset: =>
        super
        app.handler.connection.unbind "connected", @reset
        $('#home_login_submit').prop "disabled", false
