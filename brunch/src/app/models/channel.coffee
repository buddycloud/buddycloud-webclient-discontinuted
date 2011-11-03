{ Model } = require 'models/base'
{ NodeStore } = require 'collections/node'
{ gravatar } = require 'util'

##
# Attribute id: Jabber-Id
# Attribute jid: Jabber-Id
class exports.Channel extends Model
    initialize: ->
        @id = @get 'id'
        @last_touched = new Date
        @nodes = new NodeStore channel:this
        @avatar = gravatar @id, s:50, d:'retro'
        @nodes.fetch()

        # Auto-create the default set of nodes for that channel, so
        # that its data can be retrieved via XMPP
        ["posts", "status", "subscriptions",
         "geo/previous", "geo/current", "geo/next"].forEach (type) =>
            nodeid = "/user/#{@id}/#{type}"
            @nodes.get_or_create {id:nodeid, nodeid}

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
