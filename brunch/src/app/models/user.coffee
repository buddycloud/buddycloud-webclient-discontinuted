{ Model } = require 'models/base'
{ UserMetadata } = require 'models/metadata/user'
{ UserChannels } = require 'collections/channel'
{ gravatar } = require 'util'

class exports.User extends Model

    initialize: ->
        # id and jid are the same
        @id = @get('jid') or @get('id')
        @save {jid: @id, @id}
        unless typeof @get('jid') is 'string'
            console.error 'User', @, 'jid', @get('jid')
            console.trace()
        @avatar = gravatar @id, s:50, d:'retro'
        # subscribed channels
        @channels = new UserChannels parent:this
        @metadata = new UserMetadata parent:this

    push_subscription: (subscription) ->
        if subscription.jid is @get('jid')
            @trigger "subscription:user:#{@get 'jid'}", subscription

    push_affiliation: (affiliation) ->
        if affiliation.jid is @get('jid')
            @trigger "affiliation:user:#{@get 'jid'}", affiliation
