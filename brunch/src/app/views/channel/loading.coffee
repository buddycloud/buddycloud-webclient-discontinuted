
class exports.LoadingChannelView extends Backbone.View
    template: require 'templates/channel/loading'

    initialize: ->
        @bind 'hide', @hide
        do @render

    render: =>
        @el = $(@template())
        $('.centerBox').remove()

    hide: =>
        @el.remove()

