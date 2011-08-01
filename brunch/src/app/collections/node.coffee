lookup = _loaded:no
lazyRequire = -> # to prevent require circles
    { PostsNode:lookup.posts } = require 'models/node/posts'
    { MoodNode :lookup.mood  } = require 'models/node/mood'
    { GeoNode  :lookup.geo   } = require 'models/node/geo'
    { Node     :lookup.node  } = require 'models/node/skeleton'
    lookup._loaded = yes

getid = (nodeid) ->
    # "/user/:jid/posts/stuff" → ["/user/:jid/posts", ":jid", "channel"]
    match = nodeid.match(/\/user\/([^\/]+)\/([^\/]+)/)[2]


class exports.Nodes extends Backbone.Collection
    sync: -> Backbone.sync.apply(this, arguments) if @localStorage
    constructor: ->
        do lazyRequire unless lookup._loaded
        super

    _prepareModel: (model) ->
        #little hack to change the model class to a specific one (defined by id)
        @model = lookup[model.id] or lookup.node
        super

    get: (nodeid, full) ->
        if full
            super getid nodeid
        else
            super nodeid

    create: (nodeid, opts) ->
        return super(nodeid, opts) unless typeof nodeid is 'string'
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
