{ BaseView } = require '../base'
{ TopicPostView } = require './topicpost'

class exports.PostsView extends BaseView
    template: require '../../templates/channel/posts'
#     tutorial: require '../../templates/channel/tutorial.eco'
#     empty:    require '../../templates/channel/empty.eco'

    # @parent is ChannelView
    # @el will be passed by @parent
    # @model is a PostsNode
    initialize: ->
        super
        @views = {}
#         @model.bind 'change', throttle_callback(50, @render)
        @model.posts.forEach @add_post
        @model.posts.bind 'add', @add_post

    ##
    # TODO add different post type switch here
    # currently only TopicPosts are supported
    add_post: (post) =>
        @$('.tutorial, .empty').remove()
        view = @views[post.cid] ?= new TopicPostView
            model:post
            parent:this
        view.render =>
            @insert_post_view view

        post.bind 'change', =>
            return unless view.rendered
            view.el.detach()
            @insert_post_view view

    insert_post_view: (view) =>
        i = @model.posts.indexOf(view.model)
        olderPost = @views[@model.posts.at(i + 1)?.cid]
        if olderPost
            olderPost.ready ->
                olderPost.el.before view.el
        else
            @ready =>
                @el.append view.el

#
#         @$('.tutorial, .empty').remove()
#         if not @parent.isLoading and count is 0
#             if app.users.current.get('id') is @parent.model.get('id') # FIXME show tutorial for all users which have write access
#                 @el.append @tutorial()
#             else
#                 @el.append @empty()
#
#         # Still scrolled to bottom? Try cause loading more.
#         app.views.index?.on_scroll?()

    on_scroll_bottom: =>
        @load_more()

    load_more: =>
        if @model.can_load_more_posts() and
           not @model.collection.channel.isLoading
            @model.collection.channel.set_loading true
            app.handler.data.get_more_node_posts @model, =>
                @model.collection.channel.set_loading false
