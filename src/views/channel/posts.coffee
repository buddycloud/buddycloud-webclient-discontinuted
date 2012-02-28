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

        @model.bind 'unsync', =>
            setTimeout =>
                channel = app.channels.get @model.get('nodeid')
                app.handler.data.refresh_channel channel.get('id')
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
        i = @model.posts.indexOf(view.model)
#         console.error "============================", i
        @ready =>
            @trigger('view:topic:insert', i, (done) ->
#                 console.error "insert", i, view.cid
                view.ready ->
                    view.domready ->
#                         console.error "domeready => ", i, view.el
                        view.__defineGetter__('_jquery',->view.el) # FIXME wtfuck?
                        done()
            )
        view.render()

# FIXME this code should work again, i guess
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
