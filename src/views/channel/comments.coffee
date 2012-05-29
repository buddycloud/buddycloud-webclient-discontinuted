{ PostsBaseView } = require './postsbase'
{ PostView } = require './post'
{ EventHandler } = require '../../util'

class exports.CommentsView extends PostsBaseView
    ns: 'comment'
    template: require '../../templates/channel/comments'

    events:
        'keydown .answer textarea': 'hitEnterOnComment'
        'click .createComment': 'createComment'

    hitEnterOnComment: (ev) ->
        code = ev.keyCode or ev.which
        if code is 13 and ev.ctrlKey # CTRL + Enter
            ev?.preventDefault?()
            @createComment(ev)
            return false
        return true

    createComment: EventHandler ->
        if @isPosting
            return
        @$('.answer .postError').remove()
        text = @$('textarea')
        unless text.val() is ""
            text.attr "disabled", "disabled"
            @isPosting = true
            post = @createPost(content:text.val())
            node = @model.parent.collection.parent
            app.handler.data.publish node, post, (error) =>
                # Re-enable form
                @isPosting = false
                text.removeAttr "disabled"
                unless error
                    # Reset form
                    @$('.answer').removeClass 'write'
                    text.val ""
                    # clear localStorage
                    text.trigger 'txtinput'
                else
                    console.error "postError", error
                    @show_comment_error error

    createPost: (value = {}) ->
        return _.extend({
            content: ""
            author:
                name: app.users.current.get 'jid'
            in_reply_to:  @model.parent.get 'jid'
        }, value)

    createView: (opts = {}) ->
        opts.type ?= 'comment'
        new PostView opts

    indexOf: (model) ->
        @model.indexOf(model)

    show_comment_error: (error) =>
        p = $('<p class="postError"></p>')
        @$('.answer .controls').prepend(p)
        p.text(error.text or error.condition)

    render: (callback) ->
        super ->
            @model.forEach @add_post
            @model.bind 'add', @add_post

            @$('.answer').click() unless @$('.answer textarea').val() is ""

            callback?.call(this)

#     update_attributes: ->
#         @user = @parent.parent.parent.user # topicpostview.postsview.channelview

