{ User } = require 'models/user'


class exports.DataHandler extends Backbone.EventHandler

    constructor: (@connector) ->
        @get_node_subscriptions = @connector.get_node_subscriptions
        @get_user_subscriptions = @connector.get_user_subscriptions
        @get_affiliations       = @connector.get_affiliations

        @connector.bind 'post', @on_node_post
        @connector.bind 'affiliation', @on_affiliation
        @connector.bind 'subscription:user', @on_user_subscription
        @connector.bind 'subscription:node', @on_node_subscription
        @connector.bind 'connection:start', @on_prefill_from_cache
        @connector.bind 'connection:established', @on_connection_established

    get_node_metadata: (node, callback) ->
        @connector.get_node_metadata node.get('nodeid'), callback

    publish: (node, item, callback) ->
        @connector.publish node.get('nodeid'), item, callback

    add_post: (node, post) ->
        @on_node_post post, node.get 'nodeid'

    subscribe: (node, callback) ->
        @connector.subscribe node.get('nodeid'), callback

    unsubscribe: (node, callback) ->
        @connector.unsubscribe node.get('nodeid'), callback


    # event callbacks

    on_node_post: (post, nodeid) =>
        #app.error "GOT post", nodeid, post
        channel = app.channels.get nodeid
        node = channel.nodes.get nodeid, true
        node.posts.add post

    on_connection_established: =>
        user = app.users.current
        return if user.get('jid') is "anony@mous"

        @get_affiliations()
        @get_user_subscriptions()

        #nodeid = "/user/#{app.users.current.get 'jid'}/channel"
        #@connector.start_fetch_node_posts nodeid
        #@connector.get_node_posts nodeid
        # query for metadata updates for all nodes of each channel where the current user is involved
        app.channels.forEach (channel) =>
            channel.nodes.forEach (node) =>
                node.fetch()
                nodeid = node.get 'nodeid'
                @connector.get_node_posts nodeid
                if user.affiliations.get nodeid
                    node.metadata.query()

    on_prefill_from_cache: =>
        app.users.current = app.handler.connection.user
        app.channels.fetch()

        app.users.forEach (user) ->
            user.affiliations.fetch()

        # filter all channels to get only current user specific ones
        user = app.users.current
        user.affiliations.fetch()
        user.affiliations.forEach (affiliation) ->
            return if affiliation.get('value') in ['none', 'outcast']
            channel = app.channels.get affiliation.id
            user.channels.update channel

    on_affiliation: (affiliation) =>
        return unless /\/user\/([^\/]+@[^\/]+)\//.test affiliation.node
        app.debug "GOT affiliation", affiliation

        user = app.users.get affiliation.jid, yes
        user.affiliations.update affiliation.node, affiliation.affiliation

        channel = app.channels.get affiliation.node
        node = channel.nodes.create affiliation.node
        channel = user.channels.update channel

    # TODO: y distinguish between user & node subscription? A
    # subscription always pertains both!
    on_user_subscription: (subscription) =>
        # FIXME delete all unsubscripted subscriptions from local cache
        return unless /\/user\/([^\/]+@[^\/]+)\//.test subscription.node
        app.debug "GOT user subscription", subscription

        user = app.users.get subscription.jid, yes
        user.subscriptions.update subscription.node, subscription.subscription

        channel = app.channels.get subscription.node
        node = channel.nodes.create subscription.node

        # sideeffect: update sidebar by updating current user channels
        channel = user.channels.update channel
        @connector.get_node_posts subscription.node

        if user.get('id') is app.users.current.get('id')
            node.fetch()
            node.metadata.query()
            app.users.current.channels.update channel

    on_node_subscription: (subscription) =>
        app.debug "GOT node subscription", subscription
        # TODO

