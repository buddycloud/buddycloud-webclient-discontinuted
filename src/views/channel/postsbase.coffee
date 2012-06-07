{ BaseView } = require '../base'

class exports.PostsBaseView extends BaseView

    initialize: ->
        @views = {}
        super

    createPost: (value = {}) ->
        _.extend({
            content: ""
            author:
                name: app.users.current.get 'id'
        }, value)

    ##
    # TODO add different post type switch here
    # currently only TopicPosts are supported
    add_post: (post) =>
        view = @views[post.cid] ?= @createView
            model:post
            parent:this
        return if view.rendering
        i = @indexOf(view.model)
        view.on 'template:create', (tpl) =>
            @trigger "view:#{@ns}", i, tpl
        view.render()

