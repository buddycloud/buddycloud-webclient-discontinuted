{ PostsBaseView } = require './postsbase'
{ TopicPostView } = require './topicpost'

class exports.PostsView extends PostsBaseView
    ns: 'topic'
    template: require '../../templates/channel/posts'
#     tutorial: require '../../templates/channel/tutorial.eco'
#     empty:    require '../../templates/channel/empty.eco'

    # @parent is ChannelView
    # @model is a PostsNode
    initialize: ->
        super

        @model.bind 'unsync', =>
            setTimeout =>
                app.handler.data.refresh_channel @getChannel().get('id')
            , 50

    render: (callback) ->
        super ->
            @model.posts.forEach @add_post
            @model.posts.bind 'add', @add_post
            callback()

    createView: (opts = {}) ->
        new TopicPostView opts

    getChannel: () ->
        app.channels.get @model.get('nodeid')

    indexOf: (model) ->
        @model.posts.indexOf(model)

    sort: () =>
        @model.posts.sort()

    on_scroll: (peepholeTop, peepholeBottom) =>
        return unless @rendered
        for own cid, view of @views
            content = view.model.get('content')?.value
            unless content?
                { top: viewTop } = view.$el?.position() ? {top:0}
                viewBottom = viewTop + (view.$el?.outerHeight() ? 0)
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
