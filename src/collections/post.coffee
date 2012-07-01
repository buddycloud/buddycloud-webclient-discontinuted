{ Collection } = require './base'
{ Post } = require '../models/post'

class exports.Posts extends Collection
    model: Post

    constructor: ({@parent}) ->
        super()

    initialize: ->
        @parent.on('post', @get_or_create.bind(this))
        @on('change:updated',   @update_time)
        @on('change:published', @update_time)

    update_time: (post) =>
        @trigger('update:time', post)
        post.trigger('update:time')
        @sort()

    comparator: (post) ->
        - new Date(post.get_last_update()).getTime()


class exports.Comments extends exports.Posts
    comparator: (post) ->
        -1 * super(post) # comments have a reversed posts order

