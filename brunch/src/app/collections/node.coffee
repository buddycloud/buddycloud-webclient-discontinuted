lookup = _loaded:no
lazyRequire = -> # to prevent require circles
    { SubscriptionsNode:lookup.subscriptions } = require 'models/node/subscriptions'
    { StatusNode:lookup.status } = require 'models/node/status'
    { PostsNode :lookup.posts  } = require 'models/node/posts'
    { GeoNode   :lookup.geoloc } = require 'models/node/geo'
    { Node      :lookup.node   } = require 'models/node/base'
    lookup._loaded = yes

getid = (nodeid) ->
    # "/user/:jid/posts/stuff" → ["/user/:jid/posts", ":jid", "channel"]
    nodeid?.match(/\/user\/([^\/]+)\/([^\/]+)/)?[2]


class exports.Nodes extends Backbone.Collection
    sync: -> Backbone.sync.apply(this, arguments) if @localStorage
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
        id = getid(nodeid) or nodeid
        super id

    ##
    # @param opts Optional flags, such as silent: true
    create: (nodeid, opts) ->
        unless typeof nodeid is 'string'
            return super(nodeid, opts)

        id = getid nodeid
        if (node = @get id)
            node.update nodeid
            node
        else
            super {id, nodeid}, opts
            @get id




class exports.NodeStore extends exports.Nodes
    constructor: (@channel) ->
        @localStorage = new Store "#{@channel.get 'jid'}-nodes"
        app.debug "nr of channel #{@channel.get 'jid'} nodes in cache: #{@localStorage.records.length}", arguments
        super()

        @channel.bind 'subscription', (subscription) =>
            node = @create(subscription.node)
            node.push_subscription subscription
        @channel.bind 'post', (nodeid, post) =>
            node = @create(nodeid)
            node.push_post post
