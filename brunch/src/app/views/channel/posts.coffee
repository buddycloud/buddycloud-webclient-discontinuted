{ TopicPostView } = require 'views/channel/topicpost'

class exports.PostsView extends Backbone.View
    initialize: ({@parent, @el}) ->
        # INFO @el will be set by parent
        @el.attr id:@cid
        @posts = {}
        @model.bind "change", @render
        @model.posts.forEach @add_post
        @model.posts.bind "add", @add_post

    ##
    # TODO add different post type switch here
    # currently only TopicPosts are supported
    add_post: (post) =>
        console.log 'add_post'
        entry = @posts[post.cid] ?= new TopicPostView model:post, parent:this

        i = @model.posts.indexOf(post)
        console.log "i=#{i}"
        if i >= @model.posts.length - 1
            @el.append entry.el
        else
            olderPost = @posts[@model.posts.at(i + 1).cid]
            olderPost.el.before entry.el
        do entry.render

    render: =>
        for cid, entry of @posts
            entry.render()
