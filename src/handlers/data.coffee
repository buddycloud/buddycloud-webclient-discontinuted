{ User } = require '../models/user'
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

    # TODO: @param node {Node model}
    get_node_posts: (node, callback) ->
        nodeid = node.get?('nodeid') or node
        if typeof node is 'string'
            channel = app.channels.get_or_create id:nodeid
            node = channel.nodes.get_or_create nodeid:nodeid

        # Reset pagination
        node.push_posts_rsm_last null

        @connector.get_node_posts nodeid, null, (err, posts) =>
            unless err
                # Success retrieving first page?
                node.on_posts_synced()
            callback? err, posts

    get_more_node_posts: (node, callback) ->
        nodeid = node.get?('nodeid') or node
        if typeof node is 'string'
            channel = app.channels.get_or_create id:nodeid
            node = channel.nodes.get_or_create nodeid:nodeid

        rsm_after = node.posts_rsm_last
        @connector.get_node_posts nodeid, rsm_after, callback

    get_node_metadata: (node, callback) ->
        nodeid = node.get?('nodeid') or node
        @connector.get_node_metadata nodeid, callback

    set_node_metadata: (node, metadata, callback) ->
        nodeid = node.get?('nodeid') or node
        @connector.set_node_metadata nodeid, metadata, callback

    get_node_subscriptions: (node, callback) ->
        nodeid = node.get?('nodeid') or node
        if typeof node is 'string'
            channel = app.channels.get_or_create id:nodeid
            node = channel.nodes.get_or_create nodeid:nodeid

        # Reset pagination
        node.push_subscribers_rsm_last null

        @connector.get_node_subscriptions nodeid, null, (err, subscribers) =>
            unless err
                # Success retrieving first page?
                node.on_subscribers_synced()
            callback? err, subscribers

    get_more_node_subscriptions: (node, callback) ->
        nodeid = node.get?('nodeid') or node
        if typeof node is 'string'
            channel = app.channels.get_or_create id:nodeid
            node = channel.nodes.get_or_create nodeid:nodeid

        rsm_after = node.subscribers_rsm_last
        @connector.get_node_subscriptions nodeid, rsm_after, callback

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

    get_user_subscriptions: (jid, callback) =>
        nodeid = "/user/#{jid}/subscriptions"

        if jid isnt "anony@mous"
            rsmAfter = null
            step = =>
                @connector.get_node_posts nodeid, rsmAfter, (err, posts) =>
                    # TODO: synced?
                    if not posts?.rsm?.after or posts?.rsm?.after is rsmAfter
                        # Final page
                        app.users.get(jid).subscriptions_synced = app.users.current.channels.get(nodeid)?
                        callback? err
                    else
                        # Next page
                        rsmAfter = posts.rsm.after
                        step()
            step()
        else
            # anony@mous has no retrievable subscriptions
            callback?()

    # event callbacks

    on_node_post: (post, nodeid) =>
        unless @isLoading
            post.unread = true
        channel = app.channels.get_or_create id:nodeid
        channel.push_post nodeid, post

    on_node_posts_rsm_last: (nodeid, rsmLast) =>
        channel = app.channels.get_or_create id:nodeid
        # FIXME: more indirection like above?
        node = channel.nodes.get_or_create id:nodeid
        # Push info to retrieve next page
        node.push_posts_rsm_last rsmLast

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
            pending = 2
            done = =>
                pending--
                if pending < 1
                    @set_loading false
            @get_user_subscriptions app.users.current.get('id'), (error) =>
                done()
                @scan_roster_for_channels()
            @connector.replayNotifications mamStart, done

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
            # 2: get_node_posts + get_node_metadata
            pending = 2
            done = ->
                pending--
                if pending < 1
                    callback2()

            unless node.posts_synced
                @get_node_posts nodeid, done
            else
                done()
            unless node.metadata_synced
                @get_node_metadata nodeid, done
            else
                done()
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
