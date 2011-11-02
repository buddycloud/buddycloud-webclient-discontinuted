{ TopicPostView } = require 'views/channel/topicpost'

class exports.PostsView extends Backbone.View
    initialize: ({@parent, @el}) ->
        # INFO @el will be set by parent
        @el.attr id:@cid
        @views = {}
        @model.bind 'change', @render
        @model.posts.forEach @add_post
        @model.posts.bind 'add', @add_post

    ##
    # TODO add different post type switch here
    # currently only TopicPosts are supported
    add_post: (post) =>
        view = @views[post.cid] ?= new TopicPostView model:post, parent:this
        @insert_post_view view

        post.bind 'change', =>
            view.el.detach()
            @insert_post_view view

    insert_post_view: (view) =>
        i = @model.posts.indexOf(view.model)
        olderPost = @views[@model.posts.at(i + 1)?.cid]
        if olderPost
            olderPost.el.before view.el
        else
            @el.append view.el
        view.render()

    render: =>
        for cid, view of @views
            view.render()
