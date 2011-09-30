{ NodeMetadata } = require 'models/metadata/node'
{ Users } = require('collections/user')
{ Posts } = require('collections/post')

class exports.Node extends Backbone.Model
    initialize: ->
        nodeid = @get 'nodeid'
        @metadata = new NodeMetadata this, nodeid
        #@users    = new Users app.users.filter_by_node nodeid
        @posts    ?= new Posts(parent: this)
        console.warn "Posts nouvelles", @posts

    toJSON: (full) ->
        result = super
        if full
            result.metadata = @metadata.toJSON()
        result

    fetch: ->
        app.handler.data.get_node_subscriptions @get 'nodeid'
        @metadata.fetch()

    # I am very afraid of the dead. They walk.
    update: -> # api function - every node should be updateable

    push_subscription: (subscription) ->
        @trigger 'subscription', subscription

    push_post: (post) ->
        @trigger 'post', post


