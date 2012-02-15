{ Model } = require './base'
{ NodeStore } = require '../collections/node'
{ gravatar } = require '../util'

##
# Attribute id: Jabber-Id
# Attribute jid: Jabber-Id
class exports.Channel extends Model
    initialize: ->
        @_unread_count = 0
        @id = @get 'id'
        @last_touched = new Date
        @nodes = new NodeStore channel:this
        @avatar = gravatar @id
        @nodes.fetch()

        # Auto-create the default set of nodes for that channel, so
        # that its data can be retrieved via XMPP
        ["posts", "status", "subscriptions",
         "geo/previous", "geo/current", "geo/next"].forEach (type) =>
            nodeid = "/user/#{@id}/#{type}"
            node = @nodes.get_or_create {id:nodeid, nodeid}
            node.bind 'change:unread', =>
                app.debug "channel got unread"
                @trigger 'change:node:unread'

    push_post: (nodeid, post) ->
        @trigger 'post', nodeid, post

    # subscription.jid is already filtered for this channel id (user)
    push_subscription: (subscription) ->
        # subscription.subscription is either subscribed, unsubscribed or pending
        @trigger 'subscription', subscription

    push_affiliation: (affiliation) ->
        @trigger 'affiliation', affiliation

    push_metadata: (nodeid, metadata) ->
        @trigger 'metadata', nodeid, metadata

    push_node_error: (nodeid, error) ->
        @trigger 'node:error', nodeid, error

    set_loading: (@isLoading) =>
        if @isLoading
            @trigger 'loading:start'
        else
            @trigger 'loading:stop'

    count_unread: ->
        last_view = @get('last_view') or (new Date 0).toISOString()
        count = 0
        for post in (@nodes.get('posts')?.posts.models or [])
            if post.get_last_update() > last_view
                count++
            else break
        @trigger 'bubble'
        app.favicon(count - @_unread_count) # only add new ones
        @_unread_count = count
        count

    mark_read: ->
        last_view = @get('last_view') or (new Date 0).toISOString()
        last_update = @nodes.get('posts').posts.at(0)?.get_last_update()
        if last_update and last_update > last_view
            last_view = last_update
        app.favicon(@_unread_count * -1) # remove them
        @_unread_count = 0
        @save { last_view }
