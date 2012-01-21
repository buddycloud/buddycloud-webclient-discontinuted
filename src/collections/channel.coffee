{ Collection } = require './base'
{ Channel } = require '../models/channel'
{ nodeid_to_user } = require '../util'


##
# collects model/channel by Jabber-Id
class exports.Channels extends Collection
    model: Channel

    ##
    # Allow listening for specific channels to avoid calling too many
    # handlers on one generic 'add' event.
    #
    # 'add' & 'remove' events only for now
    initialize: ->
        super
        @bind 'add', (channel, channels, opts) =>
            @trigger "add:#{channel.get 'id'}", channel, channels, opts
            channel.bind 'post:change', (post) =>
                @touch channel, date:post.get_last_update()
        @bind 'remove', (channel, channels, opts) =>
            @trigger "remove:#{channel.get 'id'}", channel, channels, opts

    get: (id, options = {}) ->
        id = nodeid_to_user(id) or id
        super(id, options)

    filter: (filter) ->
        return @models if not filter? or filter is ""
        filter = filter.toLowerCase()
        super (channel) ->
            # FIXME only id to check, there meight be more (hope so)
            if (id = channel.get('id'))?
                id.toLowerCase().indexOf(filter) > -1

            else
                # nothing to compare with, channel must be empty, so we can ignore it
                no

    touch: (channel, opts = {}) =>
        channel.last_touched = opts.date or new Date
        @sort(silent:true)
        @trigger 'change' unless opts.silent

    comparator: (channel) ->
        return new Date(channel.get_last_update()).getTime()


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
                    @get_or_create id: subscription.node
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

    get: (id, options) ->
        id = nodeid_to_user(id) or id
        super(id, options)

    get_or_create: (attrs, options) ->
        super(app.channels.get_or_create(attrs, options), options)


    # overriding backbone internals
    # because code order matters
    _add: ->
        channel = super
        @parent.set channel_ids: @map((channel) -> channel.get 'id')
        channel

    ##
    # From when do we need to catch up?
    #
    # Probably since newest post viewed
    get_last_timestamp: ->
        timestamp = null
        @each (channel) ->
            last_view = channel.get 'last_view'
            if not timestamp or last_view > timestamp
                timestamp = last_view
        timestamp

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
