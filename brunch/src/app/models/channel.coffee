{ NodeStore } = require 'collections/node'
{ gravatar } = require 'util'

##
# Attribute id: Jabber-Id
# Attribute jid: Jabber-Id
class exports.Channel extends Backbone.Model
    initialize: ->
        @id = @get 'id'
        @nodes = new NodeStore(channel: this)
        @avatar = gravatar @id, s:50, d:'retro'
        @nodes.fetch()

        # Auto-create the default set of nodes for that channel, so
        # that its data can be retrieved via XMPP
        ["posts", "status", "subscriptions",
         "geo/previous", "geo/current", "geo/next"].forEach (type) =>
            @nodes.get "/user/#{@id}/#{type}", yes

    push_post: (nodeid, post) ->
        @trigger "post", nodeid, post

    # subscription.jid is already filtered for this channel id (user)
    push_subscription: (subscription) ->
        # subscription.subscription is either subscribed, unsubscribed or pending
        @trigger "subscription:user:#{subscription.jid}", subscription

