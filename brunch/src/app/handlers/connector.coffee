{ RequestHandler } = require 'handlers/request'

class exports.Connector extends Backbone.EventHandler

    ##
    # @handler: ConnectionHandler
    constructor: (@handler, @connection) ->
        @event_queue = []
        @handler.bind 'connecting', => @trigger 'connection:start'
        @handler.bind 'connected',  => @trigger 'connection:established'
        @request = new RequestHandler
        app.handler.request = @request.handler
        @connection.buddycloud.addNotificationListener @on_notification

    replayNotifications: (start, callback) =>
        @connection.buddycloud.replayNotifications start, null, =>
            callback? null
        , (error) =>
            callback? new Error("Cannot replay notifications")

    publish: (nodeid, item, callback) =>
        @request (done) =>
            @connection.buddycloud.publishAtom nodeid, item
            , (stanza) =>
                app.debug "publish", stanza
                done()
                callback? null
            , (error) =>
                app.error "publish", nodeid, error
                done()
                callback? error

    subscribe: (nodeid, callback) =>
        @request (done) =>
            # TODO: subscribe channel
            @connection.buddycloud.subscribeNode nodeid, (stanza) =>
                app.debug "subscribe", stanza
                userJid = Strophe.getBareJidFromJid(@connection.jid)
                @trigger 'subscription',
                    jid: userJid
                    node: nodeid
                    subscription: 'subscribed' # FIXME
                done()
                callback? null
            , =>
                app.error "subscribe", nodeid
                done()
                callback? new Error("Cannot subscribe")

    unsubscribe: (nodeid, callback) =>
        @request (done) =>
            @connection.buddycloud.unsubscribeNode nodeid, (stanza) =>
                app.debug "unsubscribe", stanza
                userJid = Strophe.getBareJidFromJid(@connection.jid)
                @trigger 'subscription',
                    jid: userJid
                    node: nodeid
                    subscription: 'unsubscribed'
                done()
                callback? null
            , =>
                app.error "unsubscribe", nodeid
                done()
                callback? new Error("Cannot unsubscribe")

#     start_fetch_node_posts: (nodeid) =>
#         success = (posts) =>
#             for post in posts
#                 @trigger "post", post, nodeid
#         error = =>
#             app.error "fetch_node_posts", nodeid, arguments
#         @connection.buddycloud.getChannelPostStream nodeid, success, error

    get_node_posts: (nodeid, rsmAfter, callback) =>
        @request (done) =>
            success = (posts) =>
                for post in posts
                    if post.content?
                        @trigger "post", post, nodeid
                    else if post.subscriptions?
                        for own nodeid_, subscription of post.subscriptions
                            @trigger 'subscription', subscription
                if posts.rsm
                    @trigger 'posts:rsm:last', nodeid, posts.rsm.last
                done()
                callback? null, posts
            error = (error) =>
                app.error "get_node_posts", nodeid, arguments
                @trigger 'node:error', nodeid, error
                done()
                callback? new Error("Cannot get posts")
            @connection.buddycloud.getChannelPosts(
                { node: nodeid, rsmAfter }, success, error, @connection.timeout)

    get_node_metadata: (nodeid, callback) =>
        @request (done) =>
            success = (metadata) =>
                @trigger 'metadata', nodeid, metadata
                done()
                callback? null, metadata
            error = (error) =>
                app.error "get_node_metadata", nodeid, arguments
                @trigger 'node:error', nodeid, error
                done()
                callback? new Error("Cannot get metadata")
            @connection.buddycloud.getMetadata(
                nodeid, success, error, @connection.timeout)

    # this fetches all subscriptions to a specific node
    get_node_subscriptions: (nodeid, rsmAfter, callback) =>
        @request (done) =>
            success = (subscribers) =>
                for own user, subscription of subscribers
                    unless user is 'rsm'
                        @trigger 'subscription',
                            jid: user
                            node: nodeid
                            subscription: subscription
                if subscribers.rsm
                    @trigger 'subscribers:rsm:last', nodeid, subscribers.rsm.last
                done()
                callback? null
            error = (error) =>
                @trigger 'node:error', nodeid, error
                done()
                callback? new Error("Cannot get subscriptions")
            @connection.buddycloud.getSubscribers(
                { node: nodeid, rsmAfter }, success, error, @connection.timeout)

    ##
    # notification with type subscription/affiliation already is
    # proper obj
    on_notification: (notification) =>
        switch notification.type
            when 'subscription'
                @trigger 'subscription', notification
            when 'affiliation'
                @trigger 'affiliation', notification
            when 'posts'
                for post in notification.posts
                    @trigger 'post', post, notification.node
            when 'config'
                @trigger 'metadata', notification.node, notification.config
            else
                app.debug "Cannot handle notification for #{notification.type}"

    get_roster: (callback) =>
        @connection.roster.get (items) ->
            callback? items

    ##
    # Overwrite Backbone.EventHandler::trigger to be called delayed
    # by @work_event_queue()
    trigger: ->
        @event_queue.push arguments

        @work_event_queue()

    ##
    # Triggers events in-order with a 1ms timer in between to ensure
    # GUI responsiveness
    work_event_queue: ->
        unless @event_queue_timeout
            @event_queue_timeout = setTimeout =>
                delete @event_queue_timeout

                args = @event_queue.shift()
                if args
                    # Actual trigger:
                    Backbone.EventHandler::trigger.apply this, args
                    @work_event_queue()
            , 1
