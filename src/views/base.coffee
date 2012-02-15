{ Template } = require 'dynamictemplate'

class exports.BaseView extends Backbone.View
    template: -> new Template # empty.
    el: $('<div empty>') # so @el is always a jquery object

    initialize: ({@parent} = {}) ->
        @rendered = no

    render: (callback) ->
        @render = -> throw new Error "ffffffffffffuuuuuuuuuuuuuu"
        fail = =>
            console.error @cid + " is breaking shit!"
        timeout = setTimeout(fail, 5000)
        tpl = @template(this)
        tpl.ready =>
            clearTimeout(timeout)
            @rendered = yes
            @el = tpl.jquery
            @delegateEvents()
            callback?.call?(this)
            # invoke delayed callbackes from ready
            if @_waiting?
                cb?() for cb in @_waiting
                delete @_waiting

    ready: (callback) ->
        return unless callback?
        return callback() if @rendered
        @_waiting ?= []
        @_waiting.push callback

