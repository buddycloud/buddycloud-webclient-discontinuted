{ AuthenticationView } = require 'views/authentication/base'
{ EventHandler, getBrowserPrefix } = require 'util'

LSlpk = '__localpasswd__' # localStorage local password key

class exports.LoginView extends AuthenticationView
    cssclass: 'loginPicked'
    initialize: ->
        @el = $('#login')
        @delegateEvents()

        # get elements from login form (index.html)
        @checkbox = $('#store_local')
        @jidinput = $('#home_login_jid')
        @jidinput.autoSuggestion
            suffix: (val) ->
                if val is "" or val.indexOf("@") isnt -1
                    ""
                else
                    "@#{config.domain}"
        @userinput = @jidinput.parent().find('#auto-suggestion-'+@jidinput.prop 'id')
        @passwdinput = $('#home_login_pwd')

        @load_auth()
        super

    events:
        _.extend 'submit form': 'click_login',
                 'change #store_local': 'change_store_local',
                 AuthenticationView::events

    change_store_local: EventHandler (ev) ->
        @store_auth()

        warning = $('label[for="store_local"] > div')
        warning.css 'visibility',
            if @checkbox.is(':checked') then 'visible' else 'hidden'

    click_login: EventHandler (ev) ->
        ev.stopPropagation()
        @store_auth()

        # the form sumbit will always trigger a new connection
        jid = $('#home_login_jid').val()
        password = $('#home_login_pwd').val()
        if jid.length > 0 and password.length > 0
            @start_connection(jid, password)
            # disable the form and give feedback
            $('#home_login_submit').prop "disabled", yes
            @$('.leftBox').addClass "working"
        false

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

    load_auth: =>
        jid = localStorage.getItem 'bc-jid'
        passwd = localStorage.getItem 'bc-passwd'

        if jid? and passwd?
            @userinput.val jid
            @userinput.keyup()
            @passwdinput.val passwd
            @checkbox.attr 'checked', 'checked'
            @change_store_local()

    store_auth: =>
        if @checkbox.is ':checked'
            jid = @userinput.val()
            passwd = @passwdinput.val()
        else
            jid = null
            passwd = null

        if jid? and passwd?
            localStorage.setItem 'bc-jid', jid
            localStorage.setItem 'bc-passwd', passwd
        else
            localStorage.removeItem 'bc-jid'
            localStorage.removeItem 'bc-passwd'
