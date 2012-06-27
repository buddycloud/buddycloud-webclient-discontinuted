{ EventEmitter } = require 'events'
{ Client, Element } = require 'node-xmpp'
{ Router } = require './router'


class exports.Connection extends EventEmitter
    constructor: () ->
        # values
        @router = new Router()
        @connection = null
        # listen on various events …
        @on 'error', (err) ->
            console.error "XMPP ERROR", err
        @on('stanza', @router.handle)

    emit: (e) ->
        console.warn "emit", arguments... unless e is 'newListener'
        super

    connect: (jid, password) ->
        console.log "connecting #{jid} …"
        # if we have an old, connection close it and create a new one
        # aka reconnect
        @disconnect() if @connection?
        # connection configuration
        cfg = {
            jid,
            password,
            reconnect:on, # awesome
        }
        if config.websocket_service?
            cfg.websocketsURL = config.websocket_service
        else
            cfg.boshURL = config.bosh_service
        # create client and bind to all its various events
        @connection = con = new Client(cfg)
        @router.setConnection(con)
        # pipe events through, so app code doesnt has to relisten for
        #   events when client connection resets
        for event in ['online', 'offline', 'close', 'error', 'stanza']
            con.addListener(event, @emit.bind(this, event))
        this # prevent coffee from returning an array

    disconnect: () ->
        console.log "disconnecting …"
        return unless @connection
        @router.setConnection(null)
        # close it
        @connection.end()
        @connection.removeAllListeners() # FIXME i think this should be in node-xmpp

    test: (jid, message) ->
        @connection.send new Element('message', type:'chat', to:jid).c('body').t(message)


