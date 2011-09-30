{ Post } = require 'models/post'

class exports.Posts extends Backbone.Collection
    sync: -> # do nothing
    model: Post

    constructor: ({@parent}) ->
        super()

    initialize: ->
        @parent.bind 'post', (post) =>
            @add post

    create: ->
        throw 'up'
