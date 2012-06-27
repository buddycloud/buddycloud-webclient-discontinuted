{ EventEmitter } = require 'events'
{ XPath } = require 'ltx-xpath'


class exports.Router
    constructor: () ->
        defaultns = new XPath
        for fn in ['on', 'removeListener']
            this[fn] = defaultns[fn].bind(defaultns)
        @namespaces = {'':defaultns}

    setConnection: (@connection) ->

    handle: (stanza) =>
        for nsxpath of @namespaces # FIXME order ?
            return if nsxpath.match(stanza) # emits stanza to handlers
        console.error "unhandled stanza: #{stanza.toString()}"

    of: (xmlns, prefix) ->
        # TODO store prefix somehow …
        return (@namespaces[xmlns ? ''] ?= new XPath)

test = ->
    router.of("http://jabber.org/protocol/disco#info").on("/iq[@get]", onDiscoInfoStanza)



