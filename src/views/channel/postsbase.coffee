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
            @trigger "view:#{@ns}", i, tpl
            view.model.bind 'update', =>
                j = @indexOf(view.model)
                return if j is i
                @trigger "view:#{@ns}:remove", i
                @trigger "view:#{@ns}", j, tpl
                i = j
        view.render()

