{ TopicPostView } = require './topicpost'
{ throttle_callback } = require '../../util'

class exports.PostsView extends Backbone.View
    tutorial: require '../../templates/channel/tutorial.eco'
    empty:    require '../../templates/channel/empty.eco'

    # @parent is ChannelView
    # @el will be passed by @parent
    # @model is a PostsNode
    initialize: ({@parent, @el}) ->
        @el.attr id:@cid
        @views = {}
        @model.bind 'change', throttle_callback(50, @render)
        @model.posts.forEach @add_post
        @model.posts.bind 'add', @add_post

    ##
    # TODO add different post type switch here
    # currently only TopicPosts are supported
    add_post: (post) =>
        @$('.tutorial, .empty').remove()
        view = @views[post.cid] ?= new TopicPostView model:post, parent:this
        @insert_post_view view

        post.bind 'change', =>
            view.el.detach()
            @insert_post_view view

    insert_post_view: (view) =>
        i = @model.posts.indexOf(view.model)
        olderPost = @views[@model.posts.at(i + 1)?.cid]
        if olderPost
            view.el.insertBefore olderPost.el
        else
            @el.append view.el
        view.render()

    render: =>
        count = 0
        for cid, view of @views
            view.render()
            count++

        @$('.tutorial, .empty').remove()
        if not @parent.isLoading and count is 0
            if app.users.current.get('id') is @parent.model.get('id') # FIXME show tutorial for all users which have write access
                @el.append @tutorial()
            else
                @el.append @empty()

        # Still scrolled to bottom? Try cause loading more.
        app.views.index?.on_scroll?()

    on_scroll_bottom: =>
        @load_more()

    load_more: =>
        if @model.can_load_more_posts() and
           not @model.collection.channel.isLoading
            @model.collection.channel.set_loading true
            app.handler.data.get_more_node_posts @model, =>
                @model.collection.channel.set_loading false
