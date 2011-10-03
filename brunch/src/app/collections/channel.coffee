{ Collection } = require 'collections/base'
{ Channel } = require 'models/channel'
{ nodeid_to_user } = require 'util'


##
# collects model/channel by Jabber-Id
class exports.Channels extends Collection
    model: Channel

    get: (id, options = {}) ->
        id = nodeid_to_user(id) or id
        super(id, options)


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
                    @get_or_create id:subscription.node
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

    get_or_create: (attrs, options) ->
        super(app.channels.get_or_create(attrs, options), options)


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

    get_or_create: (attrs, options = {}) ->
        newAttrs = _.clone(attrs)
        newAttrs.id = nodeid_to_user(attrs.id) or attrs.id
        super newAttrs, options
