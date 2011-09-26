{ RequestHandler } = require 'handlers/request'

class exports.Connector extends Backbone.EventHandler

    constructor: (@handler, @connection) ->
        @handler.bind 'connecting', => @trigger 'connection:start'
        @handler.bind 'connected',  => @trigger 'connection:established'
        @request = new RequestHandler
        app.handler.request = @request.handler
        @connection.buddycloud.addNotificationListener @on_notification

    publish: (nodeid, item, callback) =>
        @request (done) =>
            @connection.pubsub.publishAtom nodeid, item
            , (stanza) =>
                app.debug "publish", stanza
                callback? stanza
                done()
            , =>
                app.error "publish", nodeid
                done()

    subscribe: (nodeid, callback) =>
        @request (done) =>
            # TODO: subscribe channel
            @connection.buddycloud.subscribeNode nodeid, (stanza) =>
                app.debug "subscribe", stanza
                userJid = Strophe.getBareJidFromJid(@connection.jid)
                @trigger 'subscription:user',
                    jid: userJid
                    node: nodeid
                    subscription: 'subscribed'
                @trigger 'subscription:node',
                    jid: userJid
                    node: nodeid
                    subscription: 'subscribed'
                callback? stanza
                done()
            , =>
                app.error "subscribe", nodeid
                done()

    unsubscribe: (nodeid, callback) =>
        @request (done) =>
            @connection.buddycloud.unsubscribeNode nodeid, (stanza) =>
                app.debug "unsubscribe", stanza
                userJid = Strophe.getBareJidFromJid(@connection.jid)
                @trigger 'subscription:user',
                    jid: userJid
                    node: nodeid
                    subscription: 'none'
                @trigger 'subscription:node',
                    jid: userJid
                    node: nodeid
                    subscription: 'none'
                callback? stanza
                done()
            , =>
                app.error "unsubscribe", nodeid
                done()

#     start_fetch_node_posts: (nodeid) =>
#         success = (posts) =>
#             for post in posts
#                 @trigger "post", post, nodeid
#         error = =>
#             app.error "fetch_node_posts", nodeid, arguments
#         @connection.buddycloud.getChannelPostStream nodeid, success, error

    get_node_posts: (nodeid, callback) =>
        @request (done) =>
            success = (posts) =>
                for post in posts
                    if post.content?
                        @trigger "post", post, nodeid
                    else if post.subscriptions?
                        for own nodeid_, subscription of post.subscriptions
                            @trigger 'subscription:user', subscription
                callback? posts
                done()
            error = =>
                app.error "get_node_posts", nodeid, arguments
                done()
            @connection.buddycloud.getChannelPosts(
                nodeid, success, error, @connection.timeout)

    get_node_metadata: (nodeid, callback) =>
        @request (done) =>
            success = (metadata) =>
                @trigger "metadata:#{nodeid}", metadata
                callback? metadata
                done()
            error = =>
                app.error "get_node_metadata", nodeid, arguments
                done()
            @connection.buddycloud.getMetadata(
                nodeid, success, error, @connection.timeout)

    # this fetches all subscriptions to a specific node
    get_node_subscriptions: (nodeid) ->
        # TODO
        # @trigger 'subscription:node', subscription

    ##
    # notification with type subscription/affiliation already is
    # proper obj
    on_notification: (notification) =>
        app.debug "on_notification", notification

        switch notification.type
            when 'subscription'
                @trigger 'subscription:user', notification
                @trigger 'subscription:node', notification
            when 'affiliation'
                @trigger 'affiliation', notification
            when 'posts'
                for post in notification.posts
                    @trigger 'post', post, notification.node
            else
                app.debug "Cannot handle notification for #{notification.type}"
