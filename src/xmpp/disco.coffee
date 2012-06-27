{ EventEmitter } = require 'events'
{ Iq } = require 'node-xmpp'
NS = require './ns'


# http://xmpp.org/extensions/xep-0030.html
class Discover extends EventEmitter
    constructor: (@connection) ->

    onStanza: (stanza) ->
        console.error "DISCO", stanza.toString()
        yes # we want this stanza

    queryInfo: (to) ->
        iq = new Iq(to:to,type:'get', id:'queryInfo:123').c('query',xmlns:NS.DISCO_INFO)
        console.log "query", iq.root().toString()
        @connection.send(iq)


Discover.Discover = Discover
module.exports = Discover
