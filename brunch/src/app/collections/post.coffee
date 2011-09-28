{ Post } = require 'models/post'

class exports.Posts extends Backbone.Collection
    model: Post

    initialize: (@parent) ->
        super()
        @parent.bind 'post', (post) =>
            @create post

    create: (attributes, opts) ->
        if (post = @get(attributes.id))
            post.set(attributes, opts)
        else
            @add attributes, opts
            @get attributes.id
