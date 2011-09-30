{ Post } = require 'models/post'

class exports.Posts extends Backbone.Collection
    model: Post

    constructor: ({@parent}) ->
        super()

    initialize: ->
        @parent.bind 'post', (post) =>
            @add post

    create: ->
        throw 'up'
