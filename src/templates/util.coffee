{ List:dtList, jqueryify } = require 'dt-list'

##
# dt-list extended with event listener bind method
# and with the right list callback.
#
# call it this way to get the tag (and not the view) into the list:
#
# list.push (done) ->
#     view.domready(done)
#
# the view should be ready
# and the template should contain a ready function call (the one down there)
#
class exports.List extends dtList
    constructor: (rootel) ->
        listcallback = jqueryify rootel
        super (pos, tag) ->
            this[pos.idx] = tag if tag?
            listcallback.call this, pos

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
            view.trigger 'dom:ready', tag

