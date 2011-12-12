
class exports.LoadingChannelView extends Backbone.View
    template: require 'templates/channel/loading'

    initialize: ->
        @bind 'hide', @hide
        do @render

    render: =>
        @el = $(@template( jid: app.users.target.get('jid') ))
        $('body').removeClass('start').addClass('center').append @el
        $('.centerBox').remove()

    hide: =>
        @el.remove()
        $('body').removeClass('center')

