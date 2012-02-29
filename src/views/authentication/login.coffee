{ AuthenticationView } = require './base'
{ EventHandler } = require '../../util'
{ getCredentials, setCredentials } = require '../../handlers/creds'


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

        # get elements from login form (index.html)
        warning = $('label[for="store_local"] > div')
        checkbox = $('#store_local')
        passwdinput = $('#home_login_pwd')
        userinput = input.parent().find('#auto-suggestion-'+input.prop 'id')

        # Always show checkbox
        $('label[for="store_local"]').show()

        creds = getCredentials()
        jid = creds?[0]
        password = creds?[1]
        if jid? and password?
            userinput.prop 'value', jid
            passwdinput.prop 'value', password
            checkbox.prop 'checked', yes
            warning.show()
        # bind warning to checkbox state
        checkbox.change ->
            if checkbox.is ':checked'
                warning.show()
            else
                setCredentials()
                warning.hide()

        @el.find('form').live 'submit', EventHandler (ev) =>
            console.warn "form submit"
            ev.stopPropagation()
            # the form sumbit will always trigger a new connection
            jid = $('#home_login_jid').val()
            password = $('#home_login_pwd').val()
            if jid.length > 0 and password.length > 0
                # Navigate to home channel first
                app.users.target ?= app.users.get_or_create(id: jid)

                @start_connection(jid, password)
                # save password
                if checkbox.is ':checked'
                    setCredentials([jid, password])
                # disable the form and give feedback
                $('#home_login_submit').prop "disabled", yes
                @el.find('.leftBox').addClass "working"
        super

    start_connection: (jid, password) ->
        @unbind 'hide', @hide
        @bind 'hide', @go_away
        app.relogin jid, password, (err) =>
            @reset()
            if err
                @error(err.message)

    reset: =>
        super
        $('#home_login_submit').prop "disabled", false
