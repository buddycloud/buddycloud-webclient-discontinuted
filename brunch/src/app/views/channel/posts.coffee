{ TopicPostView } = require 'views/channel/topicpost'

class exports.PostsView extends Backbone.View
    initialize: ({@parent, @el}) ->
        # INFO @el will be set by parent
        @el.attr id:@cid
        @views = {}
        @model.bind "change", @render
        @model.posts.forEach @add_post
        @model.posts.bind "add", @add_post

    ##
    # TODO add different post type switch here
    # currently only TopicPosts are supported
    add_post: (post) =>
        entry = @views[post.cid] ?= new TopicPostView model:post, parent:this

        i = @model.posts.indexOf(post)
        olderPost = @views[@model.posts.at(i + 1)?.cid]
        if olderPost
            olderPost.el.before entry.el
        else
            @el.append entry.el
        do entry.render

    render: =>
        for cid, entry of @views
            entry.render()
