{ BaseView } = require '../base'

class exports.PostsBaseView extends BaseView

    initialize: ->
        @views = {}
        super

    ##
    # TODO add different post type switch here
    # currently only TopicPosts are supported
    add_post: (post) =>
        view = @views[post.cid] ?= @createView
            model:post
            parent:this
        return if view.rendering
        i = @indexOf(view.model)
        view.bind 'template:create', (tpl) =>
            @trigger "view:#{@ns}", tpl
#         @ready =>
#             @trigger "view:#{@ns}:insert", i, (done) ->
#                 view.ready ->
#                     view.domready(done)
        view.render()

