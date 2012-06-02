{ Posts } = require './post'
{ TopicPost } = require '../models/topicpost'

class exports.TopicPosts extends Posts
    model: TopicPost

    onadd: (post) ->
        super # implemented on Posts only for this purpose
        post.comments.bind 'change:updated', =>
            @trigger 'change:updated'

    get_or_create: (post) ->
        if post.in_reply_to
            opener = @get_or_create {id:post.in_reply_to}
            opener.comments.get_or_create post
        else
            super

