{ Collection } = require './base'
{ Post } = require '../models/post'

class exports.Posts extends Collection
    model: Post

    constructor: ({@parent}) ->
        super()

    initialize: ->
        @parent.bind('post', @get_or_create.bind(this))
        @bind('add', @onadd.bind(this))

    onadd: (post) ->
        # Hook 'change' as Backbone Collections only sort on 'add'
        post.bind 'change', =>
            @sort(silent: true)
            post.trigger 'update', this

    comparator: (post) ->
        - new Date(post.get_last_update()).getTime()


class exports.Comments extends exports.Posts
    comparator: (post) ->
        -1 * super(post) # comments have a reversed posts order

