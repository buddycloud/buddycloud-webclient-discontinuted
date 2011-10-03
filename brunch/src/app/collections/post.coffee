{ Collection } = require 'collections/base'
{ Post } = require 'models/post'

class exports.Posts extends Collection
    model: Post

    constructor: ({@parent}) ->
        super()

    initialize: ->
        @parent.bind 'post', (post) =>
            @get_or_create post
