{ NodeStore } = require 'collections/node'
{ gravatar } = require 'util'

##
# Attribute id: Jabber-Id
# Attribute jid: Jabber-Id
class exports.Channel extends Backbone.Model
    initialize: ->
        @nodes = new NodeStore this
        @avatar = gravatar @get('jid'), s:50, d:'retro'
        @nodes.fetch()

    push_post: (nodeid, post) ->
        @trigger "post", nodeid, post

    # subscription.jid is already filtered for this channel id (user)
    push_subscription: (subscription) ->
        # subscription.subscription is either subscribed, unsubscribed or pending
        @trigger "subscription", subscription

