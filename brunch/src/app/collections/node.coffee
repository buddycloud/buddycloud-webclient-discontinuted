{ Collection } = require 'collections/base'
{ nodeid_to_type } = require 'util'

lookup = _loaded:no
lazyRequire = -> # to prevent require circles
    { SubscriptionsNode:lookup.subscriptions } = require 'models/node/subscriptions'
    { StatusNode:lookup.status } = require 'models/node/status'
    { PostsNode :lookup.posts  } = require 'models/node/posts'
    { GeoNode   :lookup.geoloc } = require 'models/node/geo'
    { Node      :lookup.node   } = require 'models/node/base'
    lookup._loaded = yes


class exports.Nodes extends Collection
    constructor: ->
        do lazyRequire unless lookup._loaded
        super

    # Backbone-internal
    _prepareModel: (model) ->
        #little hack to change the model class to a specific one (defined by id)
        @model = lookup[model.id] or lookup.node
        super

    get: (nodeid, options) ->
        nodeid = nodeid?.nodeid or nodeid
        id = nodeid_to_type(nodeid) or nodeid
        # this is what a empty node looks like
        super {id, nodeid}, options

    create: (nodeid, options) ->
        nodeid = nodeid?.nodeid or nodeid
        id = nodeid_to_type(nodeid) or nodeid
        # this is what a empty node looks like
        super {id, nodeid}, options



class exports.NodeStore extends exports.Nodes
    sync: Backbone.sync

    constructor: ({@channel}) ->
        @localStorage = new Store "#{@channel.get 'id'}-nodes"
        app.debug "nr of channel #{@channel.get 'id'} nodes in cache: #{@localStorage.records.length}", arguments
        super()

    initialize: ->
        @channel.bind "subscription:user:#{@channel.get 'id'}", (subscription) =>
            node = @get subscription.node, create:yes
            node.push_subscription subscription
        @channel.bind 'post', (nodeid, post) =>
            node = @get nodeid, create:yes
            node.push_post post

    # When creating, you must always pass a full nodeid
    get: (nodeid, options = {}) ->
        nodeid = nodeid?.nodeid or nodeid
        id = nodeid_to_type(nodeid) or nodeid
        if options.create and not id
            throw new Error "NodeID missing"
        console.warn "GET NODE FROM STORE", id, nodeid
        # this is what a empty node looks like
        super {id, nodeid}, options
