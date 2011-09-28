{ NodeStore } = require 'collections/node'
{ gravatar } = require 'util'

class exports.Channel extends Backbone.Model
    initialize: ->
        @nodes = new NodeStore this
        @avatar = gravatar @get('jid'), s:50, d:'retro'
        @nodes.bind 'all', => @trigger.apply this, arguments
        @nodes.fetch()

    push_subscription: (subscription) ->
        # subscription.subscription is either subscribed, unscribed or pending
        @trigger "subscription:#{subscription.subscription}:#{subscription.node}"

