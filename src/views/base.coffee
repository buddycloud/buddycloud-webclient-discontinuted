{ Template } = require 'dynamictemplate'

class exports.BaseView extends Backbone.View
    template: -> new Template # empty.
    el: $('<div empty>') # so @el is always a jquery object

    initialize: ({@parent} = {}) ->
        @rendered = no
        @domisready = no
        @bind 'dom:ready', =>
            @domisready = yes
            if @_waitingfordom?
                cb() for cb in @_waitingfordom
                delete @_waitingfordom

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
                cb() for cb in @_waiting
                delete @_waiting

    ready: (callback) =>
        return this unless callback?
        if @rendered
            callback()
        else
            @_waiting ?= []
            @_waiting.push callback
        return this

    domready: (callback) =>
        return this unless callback?
        if @domisready
            callback()
        else
            @_waitingfordom ?= []
            @_waitingfordom.push callback
        return this