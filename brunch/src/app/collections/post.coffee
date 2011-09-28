{ Post } = require 'models/post'

class exports.Posts extends Backbone.Collection
    model: Post

    push_post: (post) ->
        @create post

    create: (attributes, options) ->
        if (post = @get(attributes.id))
            post.save(attributes, options)
        else
            super
