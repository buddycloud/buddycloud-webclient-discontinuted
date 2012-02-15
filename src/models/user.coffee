{ Model } = require './base'
{ UserMetadata } = require './metadata/user'
{ UserChannels } = require '../collections/channel'
{ gravatar } = require '../util'

class exports.User extends Model

    initialize: ->
        # id and jid are the same
        @id = @get('jid') or @get('id')
        @save {jid: @id, @id}
        @avatar = gravatar @id
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

    getSubscriptionFor: (channel) ->
        node = app.channels.get(channel)?.nodes?.get_or_create('posts')
        subscription = node?.subscribers.get(@get 'id')?.get('subscription')
        subscription or 'none'

    getAffiliationFor: (channel) ->
        node = app.channels.get(channel)?.nodes?.get_or_create('posts')
        affiliation = node?.affiliations.get(@get 'id')?.get('affiliation')
        affiliation or 'none'

    canPost: (channel) ->
        return no if app.users.isAnonymous this

        affiliation = @getAffiliationFor(channel)
        subscription = @getSubscriptionFor(channel)
        metadata = channel.nodes.get('posts')?.metadata
        publish_model = metadata?.get('publish_model')?.value

        console.warn "canPost", channel.get('id'), publish_model, affiliation
        switch publish_model
            when 'open'
                return yes
            when 'subscribers'
                return subscription == 'subscribed'
            when 'publishers'
                return isAffiliationAtLeast affiliation, 'publisher'
            else
                return no

    canEdit: (channel) ->
        return no if app.users.isAnonymous this

        @getAffiliationFor(channel) == 'owner'


# Copied from server operations
AFFILIATIONS = [
    'outcast', 'none', 'member',
    'publisher', 'moderator', 'owner'
]
isAffiliationAtLeast = (affiliation1, affiliation2) ->
    i1 = AFFILIATIONS.indexOf(affiliation1)
    i2 = AFFILIATIONS.indexOf(affiliation2)
    if i2 < 0
        false
    else
        i1 >= i2
