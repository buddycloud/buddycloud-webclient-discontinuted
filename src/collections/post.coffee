{ Collection } = require './base'
{ Post } = require '../models/post'

class exports.Posts extends Collection
    model: Post

    constructor: ({@parent}) ->
        super()

    initialize: ->
        @parent.on('post', @get_or_create.bind(this))
        @on('add', @onadd.bind(this))
        @on 'change:updated', (post) =>
            @sort()

    onadd: (post) ->
        # do nothing. this is needed in the topicpost collection

    comparator: (post) ->
        - new Date(post.get_last_update()).getTime()


class exports.Comments extends exports.Posts
    comparator: (post) ->
        -1 * super(post) # comments have a reversed posts order

