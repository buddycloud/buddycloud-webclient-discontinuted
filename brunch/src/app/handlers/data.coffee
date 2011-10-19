{ User } = require 'models/user'


class exports.DataHandler extends Backbone.EventHandler

    constructor: (@connector) ->
        @get_node_subscriptions = @connector.get_node_subscriptions

        @connector.bind 'post', @on_node_post
        @connector.bind 'affiliation', @on_affiliation
        @connector.bind 'subscription', @on_subscription
        @connector.bind 'metadata', @on_metadata
        @connector.bind 'node:error', @on_node_error
        @connector.bind 'connection:start', @on_prefill_from_cache
        @connector.bind 'connection:established', @on_connection_established

    # TODO: @param node {Node model}
    get_node_posts: (node, callback) ->
        @connector.get_node_posts node, callback

    get_node_metadata: (node, callback) ->
        @connector.get_node_metadata node.get('nodeid'), callback

    get_node_subscriptions: (node, callback) ->
        @connector.get_node_subscriptions node.get('nodeid'), callback

    publish: (node, item, success, error) ->
        @connector.publish node.get('nodeid'), item, success, error

    add_post: (node, post) ->
        @on_node_post post, node.get 'nodeid'

    ##
    # TODO: we can get very mixed responses according to the
    # individual access_model of nodes:
    # * Success
    # * Error
    # * Pending
    subscribeUser: (user, callback) ->
        forEachUserNode user, (node, callback2) =>
            @connector.subscribe node, callback2
        , callback

    unsubscribeUser: (user, callback) ->
        forEachUserNode user, (node, callback2) =>
            @connector.unsubscribe node, callback2
        , callback

    get_user_subscriptions: (jid, callback) =>
        unless jid?
            # Default: own JID
            jid = app.users.current.get('jid')

        if jid isnt "anony@mous"
            @connector.get_node_posts "/user/#{jid}/subscriptions", callback

    # event callbacks

    on_node_post: (post, nodeid) =>
        channel = app.channels.get_or_create id:nodeid
        channel.push_post nodeid, post

    on_node_error: (nodeid, error) =>
        channel = app.channels.get_or_create id:nodeid
        channel.push_node_error nodeid, error

    on_connection_established: =>
        user = app.users.current
        if user.get('jid') is "anony@mous"
            forEachUserNode app.users.target.get('id'), (nodeid, cb) =>
                @connector.get_node_posts nodeid, cb
        else
            @connector.replayNotifications()

    on_prefill_from_cache: =>
        app.users.current = app.handler.connection.user

        app.users.forEach (user) ->
            #user.affiliations.fetch()

    on_affiliation: (affiliation) =>
        return unless /\/user\/([^\/]+@[^\/]+)\//.test affiliation.node

        user = app.users.get_or_create id: affiliation.jid
        #user.push_affiliation affiliation

        channel = app.channels.get_or_create id: affiliation.node
        #channel.push_affiliation affiliation

        return

    ##
    # Got an entry from /user/.../subscriptions
    # Got a real pubsub subscription for any node
    on_subscription: (subscription) =>
        # FIXME delete all unsubscripted subscriptions from local cache
        return unless /\/user\/([^\/]+@[^\/]+)\//.test subscription.node
        app.debug "GOT user subscription", subscription

        user = app.users.get_or_create id: subscription.jid
        user.push_subscription subscription

        channel = app.channels.get_or_create id: subscription.node
        channel.push_subscription subscription

        return

    on_metadata: (node, metadata) =>
        channel = app.channels.get_or_create id: node
        channel.push_metadata node, metadata

        return

    refresh_channel: (userid, callback) ->
        forEachUserNode userid, (nodeid, cb) =>
            pending = 3
            done = ->
                pending--
                if pending < 1
                    cb()

            @get_node_posts nodeid, done
            @get_node_metadata nodeid, done
            @get_node_subscriptions nodeid, done
        , ->
            @get_user_subscriptions userid, callback

##
# @param iter {Function} callback(node, callback)
forEachUserNode = (user, iter, callback) ->
    pending = 0
    ["posts", "status", "subscriptions",
     "geo/previous", "geo/current", "geo/next"].forEach (type) ->
        node = "/user/#{user}/#{type}"
        pending++
        iter node, ->
            pending--
            if pending < 1
                callback?()
