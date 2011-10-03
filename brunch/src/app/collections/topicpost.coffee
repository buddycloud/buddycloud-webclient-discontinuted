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
            console.warn "TopicPosts.get_or_create", opener, post
            opener.comments.get_or_create post
        else
            super

    ##
    # Alternatively searchs all comments, returns opener
    #
    # FIXME: This does not work if the opener comment comes in later
    # than the comment on that comment.
    get: (id) ->
        if (topicpost = super)
            topicpost
        else
            @find (topicpost) ->
                topicpost.comments.get(id)?


    comparator: (post) ->
        - new Date(post.get 'published').getTime()
