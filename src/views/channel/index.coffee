{ BaseView } = require '../base'


class exports.ChannelView extends BaseView
    template: require '../../templates/channel/index'

    initialize: () ->
        super

    # create posts node view when it arrives from xmpp or instant when its already cached
    init_posts: =>
        @model.nodes.unbind "add", @init_posts
        if (postsnode = @model.nodes.get 'posts')
            if (title = postnode.metadata.get('title')?.value)
                @trigger('view:title', title)
#             @postsview = new PostsView
#                 model: postsnode
#                 parent: this
            # To display posts node errors:
#             postsnode.bind 'error', @set_error
#             @set_error postsnode.error

#             do @postsview.render
#             do @render FIXME
        else
            @model.nodes.bind "add", @init_posts

