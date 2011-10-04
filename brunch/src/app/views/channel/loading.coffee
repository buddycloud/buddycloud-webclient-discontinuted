
class exports.LoadingChannelView extends Backbone.View
    template: require 'templates/channel/loading'

    initialize: ->
        @bind 'hide', @hide
        do @render

    render: =>
        @el = $(@template())
        $('body').removeClass('start').append @el
        $('.centerBox').remove()

    hide: =>
        @el.remove()

