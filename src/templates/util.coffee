{ List:dtList, jqueryify } = require 'dt-list'

class exports.List extends dtList
    constructor: (rootel) ->
        super jqueryify rootel

    bind: (emitter, ns = "") ->
        ns += ":" if ns?.length?
        for fn in "push pop insert shift unshift remove".split(' ')
            emitter.bind(ns+fn, this[fn])
        return this



exports.load_indicate = (tag) ->
    indicator = null

    timeout = setTimeout ->
        indicator = tag.$p class:'loader', ->
            @$span class:'blub'
    , 1000

    return self =
        clear: ->
            clearTimeout(timeout)
            self?.remove?()
        remove: ->
            indicator?.remove()



exports.ready = (tag, view) ->
        tag.ready ->
            view.trigger 'dom:ready'

