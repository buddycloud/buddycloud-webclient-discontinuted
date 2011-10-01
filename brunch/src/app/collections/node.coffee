{ nodeid_to_type } = require 'util'

lookup = _loaded:no
lazyRequire = -> # to prevent require circles
    { SubscriptionsNode:lookup.subscriptions } = require 'models/node/subscriptions'
    { StatusNode:lookup.status } = require 'models/node/status'
    { PostsNode :lookup.posts  } = require 'models/node/posts'
    { GeoNode   :lookup.geoloc } = require 'models/node/geo'
    { Node      :lookup.node   } = require 'models/node/base'
    lookup._loaded = yes


class exports.Nodes extends Backbone.Collection
    sync: -> # do nothing

    constructor: ->
        do lazyRequire unless lookup._loaded
        super

    ##
    # Backbone-internal
    _prepareModel: (model) ->
        #little hack to change the model class to a specific one (defined by id)
        @model = lookup[model.id] or lookup.node
        super

    get: (nodeid) ->
        id = nodeid_to_type(nodeid) or nodeid
        super id

    ##
    # @param opts Optional flags, such as silent: true
    create: (nodeid, opts) ->
        throw 'up'

        unless typeof nodeid is 'string'
            return super(nodeid, opts)

        id = nodeid_to_type nodeid
        if (node = @get id)
            node.update nodeid
            node
        else
            app.debug "Create Node", id
            @add {id, nodeid}, opts
            @get id



class exports.NodeStore extends exports.Nodes
    sync: Backbone.sync

    constructor: ({@channel}) ->
        @localStorage = new Store "#{@channel.get 'id'}-nodes"
        app.debug "nr of channel #{@channel.get 'id'} nodes in cache: #{@localStorage.records.length}", arguments
        super()

    initialize: ->
        @channel.bind "subscription:user:#{@channel.get 'id'}", (subscription) =>
            node = @get(subscription.node, yes)
            node.push_subscription subscription
        @channel.bind 'post', (nodeid, post) =>
            node = @get(nodeid, yes)
            node.push_post post

    # When creating, you must always pass a full nodeid
    get: (nodeid, create) ->
        id = nodeid_to_type(nodeid) or nodeid
        if (node = super(id))
            node
        else if create
            id = nodeid_to_type(nodeid)
            unless id and nodeid
                throw "NodeID missing"
            @add { id, nodeid }
            super(id)
