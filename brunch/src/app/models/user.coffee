{ UserMetadata } = require 'models/metadata/user'
{ UserChannels } = require 'collections/channel'
{ gravatar } = require 'util'

class exports.User extends Backbone.Model

    initialize: ->
        # id and jid are the same
        @id = @get('jid')
        @set {@id}
        @avatar = gravatar @id, s:50, d:'retro'
        # subscribed channels
        @channels = new UserChannels parent:this
        @metadata = new UserMetadata parent:this

    push_subscription: (subscription) ->
        if subscription.jid is @get('jid')
            @trigger "subscription:user:#{@get 'jid'}", subscription
