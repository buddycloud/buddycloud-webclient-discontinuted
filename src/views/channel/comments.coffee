{ BaseView } = require '../base'
{ PostView } = require './post'
{ EventHandler } = require '../../util'

class exports.CommentsView extends BaseView
    template: require '../../templates/channel/comments'

    initialize: ->
        super
        @views = {}
#         @model.bind 'change', @render
        @model.forEach @add_comment
        @model.bind 'add', @add_comment

    events:
        'click .createComment': 'createComment'

    createComment: EventHandler ->
        if @isPosting
            return
        @$('.answer .postError').remove()
        text = @$('textarea')
        unless text.val() is ""
            text.attr "disabled", "disabled"
            @isPosting = true
            post =
                content: text.val()
                author:
                    name: app.users.current.get 'jid'
                in_reply_to: @model.parent.get 'id'
            node = @model.parent.collection.parent
            app.handler.data.publish node, post, (error) =>
                # Re-enable form
                @isPosting = false
                text.removeAttr "disabled"
                unless error
                    # Reset form
                    @el.find('.answer').removeClass 'write'
                    text.val ""
                    # clear localStorage
                    text.trigger 'txtinput'
                else
                    console.error "postError", error
                    @show_comment_error error

    show_comment_error: (error) =>
        p = $('<p class="postError"></p>')
        @$('.answer .controls').prepend(p)
        p.text(error.text or error.condition)

    add_comment: (comment) =>
        view = @views[comment.cid] ?= new PostView
            type:'comment'
            model:comment
            parent:this
        if @rendered
            view.render =>
                @insert_comment_view view

        comment.bind 'change', =>
            return unless view.rendered
            view.el.detach()
            @insert_comment_view view

    insert_comment_view: (view) =>
        # Look for the next older comment
        i = @model.indexOf(view.model)
        olderComment = null
        while not olderComment and (++i) < @model.length
            olderComment = @views[@model.at(i)?.cid]
            # Only if it had been rendered
            unless olderComment.rendered
                olderComment = null
        if olderComment
            # There's an older post, insert after
            olderComment.el.after view.el
        else
            # No older, this at top
            @el.prepend view.el
#         view.render() FIXME

    render: (callback) ->
        super ->
            @rendered = yes

            if @model
                text = @$('.answer textarea')
                text.textSaver()
                text.autoResize
                    extraSpace:0
                    animate:off

                @$('.answer').click() unless text.val() is ""

            pending = 0
            @model.forEach (comment) =>
                entry = @views[comment.cid]
                if entry
                    pending++
                    entry.render =>
                        @insert_comment_view entry
                        callback?.call(this) unless --pending
                else
                    console.warn "Comment without view", comment
            callback?.call(this) unless pending

#     update_attributes: ->
#         @user = @parent.parent.parent.user # topicpostview.postsview.channelview

