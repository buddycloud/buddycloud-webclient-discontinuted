{ HomeView } = require 'views/home/show'

class exports.DirectChannelView extends Backbone.View
    template: require 'templates/home/direct'

    initialize: ({@jid}) ->
        @bind 'show', @show
        @initialized = no
        unless app.views.home
            $('body').removeClass('start').append @el = $(@template())
            $('.centerBox').remove() # FIXME ugly

    show: =>
        app.views.home?.trigger 'show'

    build: =>
        @el.remove?()
        app.router.setCurrentChannel @jid
        app.views.home.trigger 'show'

