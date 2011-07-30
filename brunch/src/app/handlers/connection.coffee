{ DataHandler } = require 'handlers/data'
{ Connector } = require 'handlers/connector'

class exports.ConnectionHandler extends Backbone.EventHandler

    # CONFIG
    BOSH_SERVICE: 'http://bosh.metajack.im:5280/xmpp-httpbind'
    DOMAIN: "buddycloud.com"
    PUBSUBSERVICE: "broadcaster.buddycloud.com"
    PUBSUBJID: "pubsub-bridge@broadcaster.buddycloud.com"

    constructor: ->
        @connected = false
        @connection = new Strophe.Connection(@BOSH_SERVICE)
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
        @user = app.users.current = app.users.get jid, yes
        app.debug "CONNECT", jid, @user
        @connection.connect jid, password, @connection_event
        @connection.buddycloud.connect @PUBSUBJID

    register: (username, password) ->
        @user = app.users.current = app.users.get "#{username}@#{@DOMAIN}"
        @connection.register.connect @DOMAIN, (status, moar...) =>

            if status is Strophe.Status.REGISTERING
                @trigger 'registering'

            else if status is Strophe.Status.REGIFAIL
                @trigger 'regifail'

            else if status is Strophe.Status.REGISTER
                @trigger 'register'
                @connection.register.fields.username = username
                @connection.register.fields.password = password
                @connection.register.submit()

            else if status is Strophe.Status.SUBMITTING
                @trigger 'submitting'

            else if status is Strophe.Status.SBMTFAIL
                @trigger 'sbmtfail'
                if @isRegistered()
                    @connection.authenticate()
                    @connection.buddycloud.connect @PUBSUBJID

            else if status is Strophe.Status.REGISTERED
                @trigger 'registered'
                @_new_register = yes
                @connection.authenticate()
                @connection.buddycloud.connect @PUBSUBJID

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
            # @announce_presence() FIXME @connector.announcePresence @user
            @trigger 'connected'
            @connection.buddycloud.createChannel() if @_new_register

        else if status is Strophe.Status.DISCONNECTED
            @connected = false
            @trigger 'disconnected'

        else if status is Strophe.Status.DISCONNECTING
            @trigger 'disconnecting'

        else if status is Strophe.Status.ATTACHED
            @trigger 'attached'
