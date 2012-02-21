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
        @views = {}
        super
        @model.posts.forEach @add_post
        @model.posts.bind 'add', @add_post

        @model.posts.bind 'unsync', =>
            setTimeout =>
                app.handler.data.refresh_channel @model.collection.parent.get('id')
            , 50

    ##
    # TODO add different post type switch here
    # currently only TopicPosts are supported
    add_post: (post) =>
        @$('.tutorial, .empty').remove()
        view = @views[post.cid] ?= new TopicPostView
            model:post
            parent:this
        return if view.rendering
        view.render =>
            @ready =>
                @insert_post_view view

#             post.bind 'change', =>
#                     view.el.detach()
#                 @insert_post_view view

    insert_post_view: (view) =>
        i = @model.posts.indexOf(view.model)
        olderPost = @views[@model.posts.at(i + 1)?.cid]
        if olderPost?.rendered
            if olderPost.el.parent().length > 0
                olderPost.el.before view.el
            else
                # wtf .. jquery's design is so b0rken m(
                dummy = $()
                dummy = dummy.add view.el
                dummy = dummy.add olderPost.el
                olderPost.el = dummy
        else if olderPost
            olderPost.ready =>
                @insert_post_view view
        else
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

    on_scroll: (peepholeTop, peepholeBottom) =>
        for own cid, view of @views
            content = view.model.get('content')?.value
            unless content?
                { top: viewTop } = view.el.position()
                viewBottom = viewTop + view.el.outerHeight()
                if peepholeBottom >= viewTop
                    return @load_more()

        if peepholeBottom >= @parent.$('.stream').innerHeight() - 10
            @on_scroll_bottom()

    on_scroll_bottom: =>
        @load_more()

    load_more: =>
        unless @model.collection.channel.isLoading
            @model.collection.channel.set_loading true
            app.handler.data.get_node_posts @model, (err, done) =>
                @model.collection.channel.set_loading false
                # Should we be loading even more?
                unless err or done
                    @parent.on_scroll()
