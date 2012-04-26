{ PostsBaseView } = require './postsbase'
{ TopicPostView } = require './topicpost'

class exports.PostsView extends PostsBaseView
    ns: 'topic'
    template: require '../../templates/channel/posts'
#     tutorial: require '../../templates/channel/tutorial.eco'
#     empty:    require '../../templates/channel/empty.eco'

    # @parent is ChannelView
    # @el will be passed by @parent
    # @model is a PostsNode
    initialize: ->
        super

        @model.bind 'unsync', =>
            setTimeout =>
                channel = app.channels.get @model.get('nodeid')
                app.handler.data.refresh_channel channel.get('id')
            , 50

    render: (callback) ->
        super ->
            @model.posts.forEach @add_post
            @model.posts.bind 'add', @add_post
            callback()

    createView: (opts = {}) ->
        new TopicPostView opts

    indexOf: (model) ->
        @model.posts.indexOf(model)

    on_scroll: (peepholeTop, peepholeBottom) =>
        return unless @rendered
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
