{ Model } = require './base'
{ UserMetadata } = require './metadata/user'
{ UserChannels } = require '../collections/channel'
{ gravatar } = require '../util'

class exports.User extends Model

    initialize: ->
        # id and jid are the same
        @id = @get('jid') or @get('id')
        @save {jid: @id, @id}
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

    isFollowing: (channel) ->
        @channels.get(channel.get 'id')?

    canEdit: (channel) ->
        node = app.channels.get(channel)?.nodes?.get('posts')
        affiliation = node?.affiliations.get(@get 'id')?.get('affiliation')
        return affiliation == 'owner'
