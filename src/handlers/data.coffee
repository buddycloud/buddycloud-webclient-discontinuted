{ User } = require '../models/user'
{ RSMQueue } = require './rsm_queue'
async = require 'async'


class exports.DataHandler extends Backbone.EventHandler

    constructor: (@connector) ->
        @connector.bind 'post', @on_node_post
        @connector.bind 'posts:rsm:last', @on_node_posts_rsm_last
        @connector.bind 'subscribers:rsm:last', @on_node_subscribers_rsm_last
        @connector.bind 'affiliation', @on_affiliation
        @connector.bind 'subscription', @on_subscription
        @connector.bind 'metadata', @on_metadata
        @connector.bind 'node:error', @on_node_error
        @connector.bind 'connection:start', @on_prefill_from_cache
        @connector.bind 'connection:established', @on_connection_established
        @connector.bind 'connection:end', @on_connection_end

        @get_posts_queue = new RSMQueue 'posts', (nodeid, rsmAfter, callback) =>
            @connector.get_node_posts { nodeid, rsmAfter }, callback
        @get_subscriptions_queue = new RSMQueue 'subscriptions', (nodeid, rsmAfter, callback) =>
            @connector.get_node_subscriptions nodeid, rsmAfter, callback
        @get_affiliations_queue = new RSMQueue 'affiliations', (nodeid, rsmAfter, callback) =>
            @connector.get_node_affiliations nodeid, rsmAfter, callback

    ##
    # Extracts and sanitizes userid part from title, then creates
    # posts & status nodes.
    create_topic_channel: (metadata, callback) ->
        userid = metadata.title.
            toLocaleLowerCase().
            replace(/\s/g, "_").
            replace(/[\"\&\'\/\:\<\>]/g, "")
        if userid.indexOf("@") < 0 and config.topic_domain
            userid = "#{userid}@#{config.topic_domain}"
        @connector.createNode "/user/#{userid}/posts", metadata, (err) =>
            if err
                return callback(err)

            @connector.createNode "/user/#{userid}/status", metadata, ->
                # Don't care about status node result if posts worked
                callback(null, userid)

    # @param node {Node model or nodeid}
    # @param callback(err, done)
    get_node_posts: (node, max=40, callback) ->
        if typeof node is 'string'
            channel = app.channels.get_or_create id:node
            node = channel.nodes.get_or_create nodeid:node

        @get_posts_queue.add node, callback

    get_node_posts_by_id: (node, ids, callback) ->
        nodeid = node.get?('nodeid') or node
        console.warn "get_node_posts_by_id", node, ids
        @connector.get_node_posts { nodeid, itemIds: ids }, callback

    get_node_metadata: (node, callback) ->
        nodeid = node.get?('nodeid') or node
        @connector.get_node_metadata nodeid, callback

    set_node_metadata: (node, metadata, callback) ->
        nodeid = node.get?('nodeid') or node
        @connector.set_node_metadata nodeid, metadata, callback

    get_node_subscriptions: (node, callback) ->
        if typeof node is 'string'
            channel = app.channels.get_or_create id:node
            node = channel.nodes.get_or_create nodeid:node

        @get_subscriptions_queue.add node, callback

    get_all_node_subscriptions: (nodeid, callback) =>
        @get_node_subscriptions nodeid, (err, results, done) =>
            if err or done
                callback?()
            else
                @get_all_node_subscriptions nodeid, callback

    get_node_affiliations: (node, callback) ->
        if typeof node is 'string'
            channel = app.channels.get_or_create id:node
            node = channel.nodes.get_or_create nodeid:node

        @get_affiliations_queue.add node, callback

    get_all_node_affiliations: (nodeid, callback) =>
        @get_node_affiliations nodeid, (err, results, done) =>
            if err or done
                callback?()
            else
                @get_all_node_affiliations nodeid, callback

    set_channel_affiliation: (userid, affiliator, affiliation, callback) =>
        forEachUserNode userid, (node, callback2) =>
            @connector.set_node_affiliation node, affiliator, affiliation, callback
        , callback

    publish: (node, item, callback) ->
        nodeid = node.get?('nodeid') or node
        @connector.publish nodeid, item, callback

    add_post: (node, post) ->
        nodeid = node.get?('nodeid') or node
        @on_node_post post, nodeid

    ##
    # TODO: we can get very mixed responses according to the
    # individual access_model of nodes:
    # * Success
    # * Error
    # * Pending
    subscribe_user: (user, callback) ->
        # We show success if subscription to at least one node worked:
        oneSuccess = false
        oneError = null
        forEachUserNode user, (node, callback2) =>
            @connector.subscribe node, (error) =>
                if error
                    oneError = error
                else
                    oneSuccess = true
                callback2()
        , =>
            callback? if oneSuccess then null else oneError
            @refresh_channel user

    unsubscribe_user: (user, callback) ->
        # We show success if unsubscribing from at least one node worked:
        oneSuccess = false
        oneError = null
        forEachUserNode user, (node, callback2) =>
            @connector.unsubscribe node, (error) =>
                if error
                    oneError = error
                else
                    oneSuccess = true
                callback2()
        , =>
            @connector.remove_from_roster user
            callback? if oneSuccess then null else oneError

    grant_subscription: (subscription, callback) ->
        newSubscriptions = {}
        newSubscriptions[subscription.get('id')] = 'subscribed'

        async.forEach @get_pending_user_subscriptions(subscription)
        , (subscription1, cb) =>
            @connector.set_node_subscriptions subscription1.get('node')
            , newSubscriptions, cb
        , callback

    deny_subscription: (subscription, callback) ->
        newSubscriptions = {}
        newSubscriptions[subscription.get('id')] = 'none'

        async.forEach @get_pending_user_subscriptions(subscription)
        , (subscription1, cb) =>
            @connector.set_node_subscriptions subscription1.get('node')
            , newSubscriptions, cb
        , callback


    # Looks if there are other nodes in the same channel that this
    # user has pending subscription to.
    get_pending_user_subscriptions: (subscription) ->
        pending_subscriptions = []

        channel = app.channels.get(subscription.get('node'))
        channel.nodes.each (node) ->
            subscription1 = node.subscribers.get subscription.get('id')
            if subscription1?.get('subscription') is 'pending'
                pending_subscriptions.push subscription1

        pending_subscriptions

    ##
    # @param callback(error, done)
    get_user_subscriptions: (jid, callback) =>
        nodeid = "/user/#{jid}/subscriptions"

        if jid isnt "anony@mous"
            @get_node_posts nodeid, callback
        else
            # anony@mous has no retrievable subscriptions
            callback?(null, true)

    get_all_user_subscriptions: (jid, callback) =>
        @get_user_subscriptions jid, (err, results, done) =>
            unless err or (not results?.length > 0) or done
                @get_all_user_subscriptions jid, callback

    # event callbacks

    on_node_post: (post, nodeid) =>
        unless @isLoading
            post.unread = true
        channel = app.channels.get_or_create id:nodeid
        channel.push_post nodeid, post

    on_node_error: (nodeid, error) =>
        channel = app.channels.get_or_create id:nodeid
        channel.push_node_error nodeid, error

    on_connection_established: =>
        user = app.users.current
        if user.get('jid') is "anony@mous"
            @refresh_channel app.users.target.get('id')
        else
            @set_loading true
            # Replay starting one day before last view
            lastView = new Date(app.users.current.channels.get_last_timestamp())
            mamStart = new Date(lastView - 23 * 60 * 60 * 1000).toISOString()

            async.parallel [ (cb) =>
                @get_all_user_subscriptions app.users.current.get('id'), cb
            , (cb) =>
                @scan_roster_for_channels()
                # return immediately:
                cb()
            , (cb) =>
                @connector.replayNotifications mamStart, cb
            ], =>
                @set_loading false

    on_connection_end: =>
        app.channels.each (channel) ->
            channel.nodes.each (node) ->
                delete node.posts_synced
                delete node.metadata_synced
        app.users.each (user) ->
            delete user.subscriptions_synced

    # Global loading state for MAM replaying, see on_connection_established above
    set_loading: (@isLoading) =>
        if @isLoading
            @trigger 'loading:start'
        else
            @trigger 'loading:stop'

    on_prefill_from_cache: =>
        app.users.current = app.handler.connection.user

        app.users.forEach (user) ->
            #user.affiliations.fetch()

    on_affiliation: (affiliation) =>
        return unless /\/user\/([^\/]+@[^\/]+)\//.test affiliation.node

        user = app.users.get_or_create id: affiliation.jid
        user.push_affiliation affiliation

        channel = app.channels.get_or_create id: affiliation.node
        channel.push_affiliation affiliation

        return

    ##
    # Got an entry from /user/.../subscriptions
    # Got a real pubsub subscription for any node
    on_subscription: (subscription) =>
        # FIXME delete all unsubscripted subscriptions from local cache
        return unless /\/user\/([^\/]+@[^\/]+)\//.test subscription.node

        user = app.users.get_or_create id: subscription.jid
        user.push_subscription subscription

        channel = app.channels.get_or_create id: subscription.node
        channel.push_subscription subscription

        return

    on_node_subscribers_rsm_last: (nodeid, rsmLast) =>
        channel = app.channels.get_or_create id:nodeid
        node = channel.nodes.get_or_create nodeid:nodeid
        # Push info to retrieve next page
        node.push_subscribers_rsm_last rsmLast

    on_metadata: (node, metadata) =>
        channel = app.channels.get_or_create id: node
        channel.push_metadata node, metadata

        return

    refresh_channel: (userid, callback) ->
        channel = app.channels.get_or_create id: userid
        if channel.isLoading
            return
        channel.set_loading true

        forEachUserNode userid, (nodeid, callback2) =>
            node = channel.nodes.get_or_create nodeid:nodeid
            async.parallel [ (callback3) =>
                console.warn "refresh_channel", nodeid, node.posts_synced
                unless node.posts_synced
                    @get_node_posts nodeid, callback3
                else
                    callback3()
            , (callback3) =>
                unless node.metadata_synced
                    @get_node_metadata nodeid, callback3
                else
                    callback3()
            ], callback2
        , =>
            channel.set_loading false
            callback?()

    ##
    # Background job that comes after MAM, when the connection is
    # hopefully idle
    scan_roster_for_channels: ->
        @connector.get_roster (items) =>
            app.debug "roster", items
            items.forEach (item) =>
                if item.subscription is 'both' or
                   item.subscription is 'to'

                    jid = item.jid
                    unless app.channels.get jid
                        # In roster, but channel did not become known
                        # during MAM.
                        # Can we discover?
                        @connector.get_node_metadata "/user/#{item.jid}/posts", (err) =>
                            unless err
                                # Worked! Go subscribe...
                                app.debug "subscribe_user", jid
                                @subscribe_user item.jid

##
# @param iter {Function} callback(node, callback)
forEachUserNode = (user, iter, callback) ->
    nodes = ("/user/#{user}/#{type}" for type in [
        "posts",
        "status",
        "subscriptions",
        "geo/previous",
        "geo/current",
        "geo/next",
    ])
    async.forEach nodes, iter, callback
