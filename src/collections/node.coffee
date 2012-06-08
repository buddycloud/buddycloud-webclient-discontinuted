{ Collection } = require './base'
{ nodeid_to_type } = require '../util'

lookup = _loaded:no
lazyRequire = -> # to prevent require circles
    { SubscriptionsNode:lookup.subscriptions } = require '../models/node/subscriptions'
    { StatusNode:lookup.status } = require '../models/node/status'
    { PostsNode :lookup.posts  } = require '../models/node/posts'
    { GeoNode   :lookup.geo    } = require '../models/node/geo'
    { Node      :lookup.node   } = require '../models/node/base'
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
        id = nodeid_to_type(nodeid) or nodeid
        # this is what a empty node looks like
        super id, options

    get_or_create: (attrs, options) ->
        newAttrs = _.clone(attrs)
        newAttrs.nodeid = attrs.nodeid or attrs.id
        newAttrs.id = nodeid_to_type(attrs.id or attrs.nodeid) or attrs.id or attrs.nodeid
        unless newAttrs.nodeid and newAttrs.nodeid.indexOf("/") >= 0
            # look at parent @channel to construct full nodeid
            newAttrs.nodeid = "/user/#{@channel.get 'id'}/#{newAttrs.id}"
        # this is what an empty node looks like
        super newAttrs, options



class exports.NodeStore extends exports.Nodes
    sync: Backbone.sync

    constructor: ({@channel}) ->
        @localStorage = new Store "#{@channel.get 'id'}-nodes"
        app.debug "nr of channel #{@channel.get 'id'} nodes in cache: #{@localStorage.records.length}", arguments
        super()

    initialize: ->
        @channel.bind 'subscription', (subscription) =>
            node = @get_or_create nodeid: subscription.node
            node.push_subscription subscription
        @channel.bind 'affiliation', (affiliation) =>
            node = @get_or_create nodeid: affiliation.node
            node.push_affiliation affiliation
        @channel.bind 'post', (nodeid, post) =>
            node = @get_or_create {nodeid}
            node.push_post post
            @channel.count_unread()
        @channel.bind 'metadata', (nodeid, metadata) =>
            node = @get_or_create {nodeid}
            node.push_metadata metadata
        @channel.bind 'node:error', (nodeid, error) =>
            node = @get_or_create {nodeid}
            node.push_error error

    # When creating, you must always pass a full nodeid
    get: (nodeid, options = {}) ->
        id = nodeid_to_type(nodeid) or nodeid
        # this is what a empty node looks like
        super id, options
