{ Template } = require 'dynamictemplate'

class exports.BaseView extends Backbone.View
    template: -> new Template # empty.

    initialize: ({@parent} = {}) ->
        @el = $(@el) # so @el is always a jquery object

    render: (callback) ->
#         oldEl = @el
#         console.log @el
        tpl = @template(this)
        tpl.ready =>
            @el = tpl.jquery
            #@el.attr id: @cid FIXME ?
#             $(oldEl).replaceWith @el
            @delegateEvents()
            callback?.call(this)
