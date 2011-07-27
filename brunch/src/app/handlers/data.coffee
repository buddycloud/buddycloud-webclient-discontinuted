{ User } = require 'models/user'


class exports.DataHandler extends Backbone.EventHandler

    constructor: (@connector) ->
        @get_node_subscriptions = @connector.get_node_subscriptions

        @connector.bind 'subscription:user', @on_user_subscription
        @connector.bind 'subscription:node', @on_node_subscription
        @connector.bind 'connection:start', @on_prefill_from_cache
        @connector.bind 'connection:established', @on_connection_established

    get_node_metadata: (node, callback) ->
        @connector.get_node_metadata node.get('nodeid'), callback

    # event callbacks

    on_connection_established: =>
        # query for metadata updates for all nodes of each channel where the current user is involved
        user = app.users.current
        app.channels.forEach (channel) ->
            channel.nodes.forEach (node) ->
                node.fetch()
                if user.affiliations.get node.get 'nodeid'
                    node.metadata.query()

    on_prefill_from_cache: =>
        app.users.fetch()
        app.channels.fetch()

        # filter all channels to get only current user specific ones
        user = app.users.current
        user.affiliations.fetch()
        user.affiliations.forEach (affiliation) ->
            return if affiliation.get('value') in ['none', 'outcast']
            channel = app.channels.get affiliation.id
            user.channels.update channel

    on_user_subscription: (subscription) =>
        # FIXME delete all unsubscripted subscriptions from local cache
        return unless /\/user\/([^\/]+@[^\/]+)\//.test subscription.node # FIXME
        app.debug "GOT user subscription", subscription

        user = app.users.get subscription.jid, yes
        user.affiliations.update subscription.node, subscription.affiliation

        channel = app.channels.get subscription.node
        node = channel.nodes.create subscription.node

        # sideeffect: update sidebar by updating current user channels
        channel = user.channels.update channel

        # FIXME typeof channel is Channels
        if user.get('id') is app.users.current.get('id')
            node.metadata.query()
            app.users.current.channels.update channel

    on_node_subscription: (subscription) =>
        app.debug "GOT node subscription", subscription
        # TODO

