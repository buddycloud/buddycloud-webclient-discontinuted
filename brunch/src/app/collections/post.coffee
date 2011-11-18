{ Collection } = require 'collections/base'
{ Post } = require 'models/post'

class exports.Posts extends Collection
    model: Post

    constructor: ({@parent}) ->
        super()

    initialize: ->
        @parent.bind 'post', (post) =>
            @get_or_create post
        @bind 'add', (post) =>
            # Hook 'change' as Backbone Collections only sort on 'add'
            post.bind 'change', =>
                @sort(silent: true)
            post.bind 'change:unread', =>
                @trigger 'change:unread'
            if post.get('unread')
                @trigger 'change:unread'

    comparator: (post) ->
        - new Date(post.get_last_update()).getTime()

    count_unread: ->
        count = 0
        @each (post) ->
            if post.get('unread')
                count++
        count

    mark_read: ->
        @each (post) ->
            post.mark_read()
