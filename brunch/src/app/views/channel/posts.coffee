{ TopicPostView } = require 'views/channel/topicpost'

class exports.PostsView extends Backbone.View
    initialize: ({@parent, @el}) ->
        # INFO @el will be set by parent
        @el.attr id:@cid
        @posts = {}
        @model.bind "change", @render
        @model.posts.forEach @add_post
        @model.posts.bind "add", @add_post

    add_post: (post) =>
        # TODO add different post type switch here
        # currently only TopicPosts are supported
        topicpost = post
        entry = @posts[post.cid] ?= new TopicPostView model:topicpost, parent:this
        do entry.render
        @el.append entry.el

    render: =>
        for cid, entry of @posts
            entry.render()
