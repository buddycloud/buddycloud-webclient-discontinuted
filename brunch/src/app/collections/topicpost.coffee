{ TopicPost } = require 'models/topicpost'

class exports.TopicPosts extends Backbone.Collection
    model: TopicPost

    constructor: ({@parent}) ->
        super()

    initialize: ->
        @parent.bind 'post', (post) =>
            @add post

    add: (post) ->
        if (current = @get post.id)
            current.set post
        else if post.in_reply_to
            opener = @get post.in_reply_to
            unless opener
                super id:post.in_reply_to
                opener = @get post.in_reply_to
            opener.comments.add post
            this
        else
            super

    comparator: (post) ->
        - new Date(post.get 'published').getTime()
