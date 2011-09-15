{ TopicPost } = require 'models/topicpost'

class exports.TopicPosts extends Backbone.Collection
    model: TopicPost

    add: (post) ->
        if current = @get post.id
            current.set post
        else if post.in_reply_to
            opener  = @get post.in_reply_to
            opener ?= @add id:post.in_reply_to
            opener.comments.add post
            opener
        else
            super

    comparator: (post) ->
        - new Date(post.get 'published').getTime()
