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
        if typeof channel is 'string'
            channel = app.channels.get(channel)
        node = channel.nodes.get_or_create(id: 'posts')
        subscription = node?.subscribers.get(@get 'id')?.get('subscription')
        subscription or 'none'

    getAffiliationFor: (channel) ->
        if typeof channel is 'string'
            channel = app.channels.get(channel)
        node = channel.nodes.get_or_create(id: 'posts')
        affiliation = node?.affiliations.get(@get 'id')?.get('affiliation')
        affiliation or 'none'

    canPost: (channel) ->
        return no if app.users.isAnonymous this

        if typeof channel is 'string'
            channel = app.channels.get(channel)

        affiliation = @getAffiliationFor(channel)
        subscription = @getSubscriptionFor(channel)
        metadata = channel.nodes.get('posts')?.metadata
        publish_model = metadata?.get('publish_model')?.value

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

    canModerate: (channel) ->
        return no if app.users.isAnonymous this

        if typeof channel is 'string'
            channel = app.channels.get(channel)

        postsnode = channel.nodes.get_or_create(id: 'posts')
        if @getAffiliationFor(channel) == 'moderator' and
           postsnode.metadata.get('channel_type')?.value is 'topic'
            yes
        else if @getAffiliationFor(channel) == 'owner'
            yes
        else
            no


# app.affiliations is sorted descending
isAffiliationAtLeast = (affiliation1, affiliation2) ->
    i1 = app.affiliations.indexOf(affiliation1 or 'none')
    i2 = app.affiliations.indexOf(affiliation2 or 'none')
    return i1 >= i2
