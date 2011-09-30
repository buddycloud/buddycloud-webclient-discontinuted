{ Post } = require 'models/post'

class exports.Posts extends Backbone.Collection
    model: Post

    constructor: ({@parent}) ->
        super()

    initialize: ->
        console.warn 'Posts binding', @
        @parent.bind 'post', (post) =>
            console.warn 'Posts got post', post, @
            @add post

    create: ->
        throw 'up'
