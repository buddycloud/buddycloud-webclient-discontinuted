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
#         console.error "============================", i
        @ready =>
            @trigger("view:#{@ns}:insert", i, (done) ->
#                 console.error "insert", i, view.cid
                view.ready ->
                    view.domready ->
#                         console.error "domeready => ", i, view.el
                        view.__defineGetter__('_jquery',->view.el) # FIXME wtfuck?
                        done()
            )
        view.render()

