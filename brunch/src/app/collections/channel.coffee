{ Collection } = require 'collections/base'
{ Channel } = require 'models/channel'
{ nodeid_to_user } = require 'util'


##
# collects model/channel by Jabber-Id
class exports.Channels extends Collection
    model: Channel


# used in models/user
class exports.UserChannels extends exports.Channels
    constructor: ({@parent}) ->
        super()

    initialize: ->
        super
        @parent.bind "subscription:user:#{@parent.get 'id'}", (subscription) =>
            switch subscription.subscription
                # FIXME get 'pending' working when we need it
                when 'subscribed', 'pending'
                    @get subscription.node, yes
                when 'unsubscribed', 'none'
                    if (channel = @get subscription.node)
                        @remove channel
        @fetch()

    sync: (method, model, options) ->
        if method is 'read'
            channels = _.map @parent.get('channel_ids') or [], (channelid) ->
                app.channels.get channelid
            options.success(channels)

    fetch: (options = {}) ->
        options.add = yes unless options.add?
        super

    get: (id, options = {}) ->
        id = nodeid_to_user(id) or id
        opts = _.clone options
        opts.create = no
        channel = super(id, opts)
        if not channel and options.create
            channel = app.channels.get id, options
            @create channel


    # overriding backbone internals
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
    sync: Backbone.sync

    initialize: ->
        super
        @localStorage = new Store("channels")
        app.debug "nr of channels in cache: #{@localStorage.records.length}"
        @fetch()

    # returns cached channel or creates new cache entry
    get: (id, options) ->
        # if options.create is on and nothing was found it creates the dummy object {id:id}
        super {id}, options
