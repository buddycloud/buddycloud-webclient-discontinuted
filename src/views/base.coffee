{ View }     = require 'backbone'
{ Template } = require 'dynamictemplate'

adapters =
    jquery: require('dt-jquery').bind(this,
        # options
        use:[
            require('dt-list/adapter/jquery')
        ]
    )
#     dom: require('dt-dom').bind(this,
#         # options
#         use:[
#             require('dt-list/adapter/dom')
#         ]
#     )

class exports.BaseView extends View
    template: -> new Template # empty.

    initialize: ({@parent} = {}) ->
        @rendered = no

    # patch some backbone internals

    make: -> # do nothing
    delegateEvents:   -> super if @$el?
    undelegateEvents: -> super if @$el?
    $:                -> super if @$el?

    setElement: (element, delegate, callback) ->
        return unless element?
        @el = element # it's actually a template instance
        @el = adapters[@adapter](@el) if @adapter
        @trigger('template:create', @el)
        @el.once 'end', =>
            @trigger('template:end', @el)
        fail = =>
            console.error @cid + " is breaking shit!"
        timeout = setTimeout(fail, 5000)
        @el.ready =>
            clearTimeout(timeout)
            @rendered = yes
            do @undelegateEvents if @$el
            @$el = @el.jquery
            do @delegateEvents if delegate isnt off
            @trigger('template:ready', @el)
            callback?.call?(this, @$el)
            # invoke delayed callbackes from ready
            if @_waiting?
                cb?() for cb in @_waiting
                @_waiting = null
        this

    render: (callback) ->
        @setElement(@template(this), null, callback)

    ready: (callback) ->
        return unless callback?
        return callback() if @rendered
        @_waiting ?= []
        @_waiting.push callback

    domready: (callback) =>
        return this unless callback?
        if @domisready
            callback(@_tag)
        else
            @_waitingfordom ?= []
            @_waitingfordom.push callback
        return this

    destroy: (opts = {}) =>
        return if @destroyed
        @trigger('destroy')
        @el?.remove() if opts.rmel ? yes
        @off() # removeAllListeners
        # remove references
        for prop in ['el', '$el', 'options', 'model', 'collection', 'parent']
            delete this[prop]
        @destroyed = yes
        Object.freeze this # You’re frozen when your heart’s not open

