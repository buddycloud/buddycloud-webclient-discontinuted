{ Collection } = require 'collections/base'
{ TopicPost } = require 'models/topicpost'

class exports.TopicPosts extends Collection
    model: TopicPost

    constructor: ({@parent}) ->
        super()

    initialize: ->
        @parent.bind 'post', (post) =>
            @add post

    add: (post) ->
        if (current = @get post)
            current.save post
        else if post.in_reply_to
            opener = @get post.in_reply_to
            unless opener
                super id:post.in_reply_to
                opener = @get post.in_reply_to
            opener.comments.create post, update:yes
            this
        else
            super

    comparator: (post) ->
        - new Date(post.get 'published').getTime()
