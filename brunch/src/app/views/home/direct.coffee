{ HomeView } = require 'views/home/show'

class exports.DirectChannelView extends Backbone.View
    template: require 'templates/home/direct'

    initialize: ({@jid}) ->
        @bind 'show', @show
        @initialized = no
        $('body').removeClass('start').append @el = $(@template())
        $('.centerBox').remove() # FIXME ugly

    show: =>
        app.views.home?.trigger 'show'

    build: =>
        do @el.remove

        user = app.users.current
        nodeid = "/user/#{@jid}/channel"
        channel = app.channels.get nodeid
        node = channel.nodes.create nodeid
        channel = user.channels.update channel

        # sideeffect: update sidebar by updating current user channels
        node.fetch()
        node.metadata.query()
        app.users.current.channels.update channel

        app.views.home = new HomeView
        app.views.home.trigger 'show'

