{ DataHandler } = require 'handlers/data'
{ Connector } = require 'handlers/connector'

class exports.ConnectionHandler extends Backbone.EventHandler
    constructor: ->
        @connected = false
        @connection = new Strophe.Connection(config.bosh_service)
        @connection.addHandler (stanza) ->
            app.debug "IN", Strophe.serialize stanza
            true
        @connector = new Connector(this, @connection) # before datahandler
        app.handler.data = new DataHandler(@connector)

        # debugging
        if app.debug_mode
            send = @connection.send
            @connection.send = (stanza) =>
                app.debug "OUT", Strophe.serialize stanza
                send.apply @connection, arguments


        # for debug purposes only
        @bind "all", (status) -> app.debug "connection_event", status

    # connect the current user with his jid and pw
    connect: (jid, password) ->
        unless jid
            jid = config.anon_domain
            @user = app.users.get "anony@mous", yes
        else
            @user = app.users.get jid, yes
        app.debug "CONNECT", jid, @user
        @connection.connect jid, password, @connection_event

    # make sure we allways have a channel
    createChannel: (done) =>
        @connection.buddycloud.createChannel done, done

    discover_channel_server: (done) =>
        if @user.get('jid') is "anony@mous"
            @connection.buddycloud.connect config.pubsubjid
            return done()

        success = (pubsubjid) =>
            app.error "discover_channel_server success", arguments
            @connection.buddycloud.connect pubsubjid
            @connection.presence.authorize pubsubjid
            @announce_presence()
            @connection.presence.addSubscribeHandler (stanza) ->
                if stanza.getAttribute('from') is pubsubjid
                    true
            @createChannel done
        error = =>
            app.error "discover_channel_server error", arguments
        @connection.buddycloud.discover config.domain, success, error

    register: (username, password, email) ->
        @user = app.users.get "#{username}@#{config.domain}", yes
        @connection.register.connect config.domain, (status, moar...) =>

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
            @discover_channel_server =>
                @trigger 'connected'

        else if status is Strophe.Status.DISCONNECTED
            @connected = false
            @trigger 'disconnected'

        else if status is Strophe.Status.DISCONNECTING
            @trigger 'disconnecting'

        else if status is Strophe.Status.ATTACHED
            @trigger 'attached'

    announce_presence: =>
        @connection.presence.set
            status: "buddycloud"