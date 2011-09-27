{ Channel } = require 'models/channel'

getid = (nodeid) ->
    # /user/u@catz.net/posts → ["/user/u@catz.net/", "u@catz.net"]
    nodeid.match(/\/user\/([^\/]+@[^\/]+)\//)[1] # jid # TODO compile


class exports.Channels extends Backbone.Collection
    sync: ->

    model: Channel

    update: (channel) ->
        existing_channel = @get channel.id
        if existing_channel
            existing_channel.set channel
            existing_channel
        else
            @add channel
            @get channel.id



# global channel collection store
# only one instance as app.channels
class exports.ChannelStore extends exports.Channels
    initialize: ->
        super
        @localStorage = new Store("channels")
        app.debug "nr of channels in cache: #{@localStorage.records.length}"

    sync: ->
        Backbone.sync.apply(this, arguments)

    # returns cached channel or creates new cache entry
    get: (nodeid) ->
        return super(nodeid) unless typeof nodeid is 'string'
        id = getid nodeid
        super(id) or @create({id, jid:id})

