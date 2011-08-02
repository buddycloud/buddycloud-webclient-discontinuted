{ RequestHandler } = require 'handlers/request'

class exports.Connector extends Backbone.EventHandler

    constructor: (@handler, @connection) ->
        @handler.bind 'connecting', => @trigger 'connection:start'
        @handler.bind 'connected',  => @trigger 'connection:established'
        @request = new RequestHandler
        app.handler.request = @request.handler

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
                    @trigger "post", post, nodeid
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

    # this fetches all user affiliations
    get_affiliations: =>
        @request (done) =>
            success = (affiliations) =>
                for affiliation in affiliations
                    @trigger 'affiliation', affiliation
                done()
            error = =>
                clearTimeout timeout
                app.error "get_affiliations", arguments
                done()
            timeout = setTimeout error, @connection.timeout
            @connection.buddycloud.getUserAffiliations success, error

    # this fetches all user channels
    get_user_subscriptions: =>
        @request (done) =>
            success = (subscriptions) =>
                for subscription in subscriptions
                    @trigger 'subscription:user', subscription
                done()
            error = =>
                clearTimeout timeout
                app.error "get_user_subscriptions", arguments
                done()
            timeout = setTimeout error, @connection.timeout
            @connection.buddycloud.getUserSubscriptions success, error

    # this fetches all subscriptions to a specific node
    get_node_subscriptions: (nodeid) ->
        # TODO
        # @trigger 'subscription:node', subscription

