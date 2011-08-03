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

        nodeid = "/user/#{@jid}/posts"
        channel = app.channels.get nodeid

        unless app.views.home
            user = app.users.current
            node = channel.nodes.create nodeid
            channel = user.channels.update channel

            # sideeffect: update sidebar by updating current user channels
            node.fetch()
            node.metadata.query()
            app.users.current.channels.update channel
            app.handler.connection.connector.get_node_posts nodeid

            app.views.home = new HomeView
        else
            app.views.home.setCurrentChannel channel.cid

        app.views.home.trigger 'show'

