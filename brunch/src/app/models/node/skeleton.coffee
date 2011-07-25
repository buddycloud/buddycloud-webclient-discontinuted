{ NodeMetadata } = require 'models/metadata/node'
{ Users } = require('collections/user')

class exports.Node extends Backbone.Model
    initialize: ->
        nodeid = @get 'nodeid'
        @metadata = new NodeMetadata this, nodeid
        @users    = new Users app.users.filter_by_node nodeid

    toJSON: (full) ->
        result = super
        if full
            result.metadata = @metadata.toJSON()
        result

    fetch: ->
        app.handler.data.get_node_subscriptions @get 'nodeid'
        @metadata.fetch()

    update: -> # api function - every node should be updateable
