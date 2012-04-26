{ Template } = require 'dynamictemplate'
{ Adapter:JQueryAdapter } = require 'dt-jquery'
addListSupport = require 'dt-list/adapter/jquery'

adapters =
    jquery: (opts, tpl) ->
        [tpl, opts] = [opts, null] unless tpl?
        addListSupport new JQueryAdapter(tpl, opts)
        return tpl


class exports.BaseView extends Backbone.View
    template: -> new Template # empty.
    el: $('<div empty>') # so @el is always a jquery object

    initialize: ({@parent} = {}) ->
        @rendered = no
        @domisready = no
        @bind 'dom:ready', (tag) =>
            @_tag = tag
            @domisready = yes
            if @_waitingfordom?
                cb(tag) for cb in @_waitingfordom
                delete @_waitingfordom

    render: (callback) ->
        @render = -> throw new Error "ffffffffffffuuuuuuuuuuuuuu"
        fail = =>
            console.error @cid + " is breaking shit!"
        timeout = setTimeout(fail, 5000)
        tpl = @template(this)
        tpl = adapters[@adapter](tpl) if @adapter
        @trigger('template:create', tpl)
        tpl.ready =>
            clearTimeout(timeout)
            @rendered = yes
            @el = tpl.jquery
            @delegateEvents()
            @trigger('template:ready', tpl)
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

    domready: (callback) =>
        return this unless callback?
        if @domisready
            callback(@_tag)
        else
            @_waitingfordom ?= []
            @_waitingfordom.push callback
        return this
