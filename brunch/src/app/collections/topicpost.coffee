{ Collection } = require 'collections/base'
{ TopicPost } = require 'models/topicpost'

class exports.TopicPosts extends Collection
    model: TopicPost

    constructor: ({@parent}) ->
        super()

    initialize: ->
        @parent.bind 'post', (post) =>
            @get_or_create post

    get_or_create: (post) ->
        if post.in_reply_to
            opener = @get_or_create {id:post.in_reply_to}
            opener.comments.get_or_create post
        else
            super

    comparator: (post) ->
        latest = new Date(post.get 'published').getTime()
        post.comments.forEach (comment) ->
            published = new Date(post.get 'published').getTime()
            if published > latest
                published = latest
        - latest
