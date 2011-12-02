{ DataHandler } = require 'handlers/data'
{ Connector } = require 'handlers/connector'

class exports.ConnectionHandler extends Backbone.EventHandler
    constructor: ->
        @connected = false
        @connector = new Connector(this) # before datahandler
        app.handler.data = new DataHandler(@connector)

        @last_login = {}

        # for debug purposes only
        @bind "all", (status) -> app.debug "connection_event", status

    # connect the current user with his jid and pw
    connect: (jid, password) ->
        if jid isnt @last_login.jid or password isnt @last_login.password
            # We're not confident anymore whether thid jid/pw pair
            # actually authenticates.
            @last_login.connected = false
        @last_login.jid = jid
        @last_login.password = password

        unless jid
            jid = config.anon_domain
            @user = app.users.get_or_create id: "anony@mous"
        else
            if jid.indexOf("@") < 0
                jid = "#{jid}@#{config.domain}"
            jid = jid.toLowerCase()
            @user = app.users.get_or_create id: jid
        app.debug "CONNECT", jid, @user

        # Set up connection
        @connection = new Strophe.Connection(config.bosh_service)
        @connection.addHandler (stanza) ->
            app.debug "IN", Strophe.serialize stanza
            true
        @connector.setConnection @connection
        # debugging
        if app.debug_mode
            send = @connection.send
            @connection.send = (stanza) =>
                app.debug "OUT", Strophe.serialize stanza
                send.apply @connection, arguments

        # workaround for development
        if window.location.hostname is "localhost"
            @connection.connect jid, password, @connection_event
            return

        jQuery.ajax
            type:'POST'
            data:'<body xmlns="http://jabber.org/protocol/httpbind"/>'
            url:config.bosh_service
            success: =>
                @connection.connect jid, password, @connection_event
            error: =>
                @trigger 'nobosh'

    reset: () ->
        app.debug "RESET", @user
        @connection.disconnect()

    # make sure we allways have a channel
    createChannel: (done) =>
        @connection.buddycloud.createChannel done, done

    discover_channel_server: (done) =>
        success = (pubsubJid) =>
            app.error "discover_channel_server success", arguments
            @connection.buddycloud.connect pubsubJid
            #@connection.presence.authorize pubsubJid
            @pubsubJid = pubsubJid
            @announce_presence()
            @connection.presence.addSubscribeHandler (stanza) ->
                if stanza.getAttribute('from') is pubsubJid
                    true
            @createChannel done
        error = =>
            app.error "discover_channel_server error", arguments
            #done()

        domain = if @user.get('jid') is "anony@mous"
                config.home_domain
            else
                Strophe.getDomainFromJid(@user.get('jid'))
        @connection.buddycloud.discover domain, success, error

    register: (username, password, email) ->
        username = username.toLowerCase()
        if (m = username.match(/^(.+)@(.+)$/))
            username = m[1]
            domain = m[2]
        else
            domain = config.domain
        @user = app.users.get_or_create id: "#{username}@#{domain}"
        @connection.register.connect domain, (status, moar...) =>

            if status is Strophe.Status.REGISTERING
                @trigger 'registering'

            else if status is Strophe.Status.REGIFAIL
                @trigger 'regifail'

            else if status is Strophe.Status.REGISTER
                @trigger 'register'
                @connection.register.fields.username = username
                @connection.register.fields.password = password
                if email
                    @connection.register.fields.email = email
                @connection.register.submit()

            else if status is Strophe.Status.SUBMITTING
                @trigger 'submitting'

            else if status is Strophe.Status.SBMTFAIL
                @trigger 'sbmtfail'
                # user accidently pressed register instead of login, so we try to authenticate as given user
                if @isRegistered()
                    @connection.authenticate()

            else if status is Strophe.Status.REGISTERED
                @trigger 'registered'
                @_new_register = yes
                @connection.authenticate()

            else @connection_event.apply(this, arguments)

    isRegistered: ->
        @connection.register.registered

    # forwards all events of the connection
    connection_event: (status) =>

        if status is Strophe.Status.ERROR
            @trigger 'error'

        else if status is Strophe.Status.CONNECTING
            @trigger 'connecting'

        else if status is Strophe.Status.CONNFAIL
            @connected = false
            @trigger 'connfail'

        else if status is Strophe.Status.AUTHENTICATING
            @trigger 'authenticating'

        else if status is Strophe.Status.AUTHFAIL
            @trigger 'authfail'

        else if status is Strophe.Status.CONNECTED
            @connected = true
            @last_login.connected = true
            @discover_channel_server =>
                @trigger 'connected'

        else if status is Strophe.Status.DISCONNECTED
            @connected = false
            @trigger 'disconnected'

        else if status is Strophe.Status.DISCONNECTING
            @trigger 'disconnecting'

        else if status is Strophe.Status.ATTACHED
            @trigger 'attached'

    announce_presence: ->
        unless @pubsubJid
            return

        @connection.presence.set
            to: @pubsubJid
            status: "buddycloud"
