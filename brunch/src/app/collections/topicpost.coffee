{ Collection } = require 'collections/base'
{ TopicPost } = require 'models/topicpost'

class exports.TopicPosts extends Collection
    model: TopicPost

    constructor: ({@parent}) ->
        super()

    initialize: ->
        @parent.bind 'post', (post) =>
            @get_or_create post
        @bind 'add', (post) =>
            post.bind 'change', =>
                @sort()

    get_or_create: (post) ->
        if post.in_reply_to
            opener = @get_or_create {id:post.in_reply_to}
            opener.comments.get_or_create post
        else
            super

    comparator: (post) ->
        console.log "TopicPosts.comparator", post, (- new Date(post.get_last_update()).getTime())
        - new Date(post.get_last_update()).getTime()
