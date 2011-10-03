{ Collection } = require 'collections/base'
{ TopicPost } = require 'models/topicpost'

class exports.TopicPosts extends Collection
    model: TopicPost

    constructor: ({@parent}) ->
        super()

    initialize: ->
        @parent.bind 'post', (post) =>
            @add post

    get_or_create: (post) ->
        if post.in_reply_to
            opener = @get_or_create {id:post.in_reply_to}
            opener.comments.get_or_create post
        else
            super

    # Alternatively searchs all comments, returns opener
    get: (id) ->
        if (topicpost = super)
            topicpost
        else
            @find (topicpost) ->
                topicpost.get(id)?


    comparator: (post) ->
        - new Date(post.get 'published').getTime()
