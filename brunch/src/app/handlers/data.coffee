{ User } = require 'models/user'


class exports.DataHandler extends Backbone.EventHandler

    constructor: (@connector) ->
        @get_node_subscriptions = @connector.get_node_subscriptions

        @connector.bind 'post', @on_node_post
        @connector.bind 'posts:rsm:last', @on_node_posts_rsm_last
        @connector.bind 'affiliation', @on_affiliation
        @connector.bind 'subscription', @on_subscription
        @connector.bind 'metadata', @on_metadata
        @connector.bind 'node:error', @on_node_error
        @connector.bind 'connection:start', @on_prefill_from_cache
        @connector.bind 'connection:established', @on_connection_established

    # TODO: @param node {Node model}
    get_node_posts: (node, callback) ->
        nodeid = node.get?('nodeid') or node
        rsm_after = node.get?('rsm_last')
        @connector.get_node_posts nodeid, rsm_after, callback

    get_node_metadata: (node, callback) ->
        nodeid = node.get?('nodeid') or node
        @connector.get_node_metadata nodeid, callback

    get_node_subscriptions: (node, callback) ->
        nodeid = node.get?('nodeid') or node
        @connector.get_node_subscriptions nodeid, callback

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
            callback? if oneSuccess then null else oneError

    get_user_subscriptions: (jid, callback) =>
        unless jid?
            # Default: own JID
            jid = app.users.current.get('jid')

        if jid isnt "anony@mous"
            @connector.get_node_posts "/user/#{jid}/subscriptions", callback
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
        channel = app.cahnnels.get_or_create id:nodeid
        # FIXME: more indirection like above?
        node = channel.nodes.get_or_create id:nodeid
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
            @connector.replayNotifications app.users.current.channels.get_last_timestamp()
            , (error) =>
                @set_loading false
                @scan_roster_for_channels()

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
        channel = app.channels.get_or_create id: userid
        channel.set_loading true
        forEachUserNode userid, (nodeid, callback2) =>
            # 3: get_node_posts + get_node_metadata + get_node_subscriptions
            pending = 3
            done = ->
                pending--
                if pending < 1
                    callback2()

            @get_node_posts nodeid, done
            @get_node_metadata nodeid, done
            @get_node_subscriptions nodeid, done
        , =>
            @get_user_subscriptions userid, =>
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
    pending = 0
    ["posts", "status", "subscriptions",
     "geo/previous", "geo/current", "geo/next"].forEach (type) ->
        nodeid = "/user/#{user}/#{type}"
        pending++
        iter nodeid, ->
            pending--
            if pending < 1
                callback?()
