{ Channel } = require 'models/channel'
{ nodeid_to_user } = require 'util'


##
# collects model/channel by Jabber-Id
class exports.Channels extends Backbone.Collection
    sync: -> # do nothing

    model: Channel

    ##
    # @return {Bool} Whether channel is new
    update: (channel) ->
        existing_channel = @get channel.id
        if existing_channel
            existing_channel.set channel
            no
        else
            @add channel
            yes

# used in models/user
class exports.UserChannels extends exports.Channels
    constructor: ({@parent}) ->
        super()

    initialize: ->
        super
        @parent.bind "subscription:user:#{@parent.get 'id'}", (subscription) =>
            console.error "UserChannels (#{@parent.get 'id'}) subscription", @, subscription
            switch subscription.subscription
                # FIXME get 'pending' working when we need it
                when 'subscribed', 'pending'
                    @get subscription.node, yes
                when 'unsubscribed', 'none'
                    if (channel = @get subscription.node)
                        @remove channel
                        console.warn "UserChannels #{@parent.get 'id'} removed", @, channel
        @fetch()

    fetch: ->
        channel_ids = _.clone(@parent.get('channel_ids') or [])
        for channelid in channel_ids
            @add app.channels.get channelid

    get: (id, create) ->
        id = nodeid_to_user(id) or id
        if (channel = super(id))
            channel
        else if create and (channel = app.channels.get(id, create))
            @add channel
            @get channel.id
        else
            null

    # overriding backbone internels
    _add: ->
        channel = super
        @parent.set channel_ids: @map((channel) -> channel.get 'id')
        channel


# global channel collection store
# only one instance as app.channels
#
# The idea is that only this collection creates models, while the
# other (filtered) collections retrieve the same singleton model
# through the *Store collections.
class exports.ChannelStore extends exports.Channels
    initialize: ->
        super
        @localStorage = new Store("channels")
        app.debug "nr of channels in cache: #{@localStorage.records.length}"
        @fetch()

    sync: Backbone.sync

    # returns cached channel or creates new cache entry
    get: (id, create) ->
        id = nodeid_to_user(id) or id
        if (channel = super(id))
            channel
        else if create
            @add(id: id)
            super(id)
