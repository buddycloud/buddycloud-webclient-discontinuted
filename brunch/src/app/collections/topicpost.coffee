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
            # Is a comment
            opener = @get post.in_reply_to
            unless opener
                # Create parent, may be retrieved later
                super id:post.in_reply_to
                opener = @get post.in_reply_to
            # TODO: Shorten that into create()/update()
            if (current = opener.comments.get(post.id))
                console.warn "updating comment #{opener.id}/#{post.id}: #{post.content.value}"
                current.set post
            else
                opener.comments.add post
            this
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
