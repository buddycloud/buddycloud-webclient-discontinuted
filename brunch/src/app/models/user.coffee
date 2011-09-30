{ UserMetadata } = require 'models/metadata/user'
{ UserChannels } = require 'collections/channel'
{ gravatar } = require 'util'

class exports.User extends Backbone.Model

    initialize: ->
        # id and jid are the same
        @set id: @get('jid')
        @avatar = gravatar @id, s:50, d:'retro'
        # subscribed channels
        @channels = new UserChannels parent:this
        @metadata = new UserMetadata parent:this

    push_subscription: (subscription) ->
        if subscription.jid isnt @get('jid')
            return

        switch subscription.subscription
            when 'subscribed'
                @channels.get subscription.node, yes
            when 'unsubscribed', 'none'
                if (channel = @channels.get subscription.node)
                    @channels.remove user

        @trigger "subscription", subscription
