{ BaseView } = require 'views/base'
{ PostView } = require 'views/channel/post'
{ EventHandler } = require 'util'

class exports.CommentsView extends BaseView
    template: require 'templates/channel/comments'

    initialize: ({@parent}) ->
        super
        @views = {}
        @model.bind 'change', @render
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
                else
                    console.error "postError", error
                    @show_comment_error error

    show_comment_error: (error) =>
        p = $('<p class="postError"></p>')
        @$('.answer .controls').prepend(p)
        p.text(error.text or error.condition)

    add_comment: (comment) =>
        entry = @views[comment.cid] ?= new PostView
            type:'comment'
            model:comment
            parent:this

        i = @model.indexOf(comment)
        olderComment = @views[@model.at(i + 1)?.cid]
        if olderComment
            olderComment.el.after entry.el
        else
            @el.prepend entry.el
        do entry.render

    render: =>
        @update_attributes()
        super

        if @model
            text = @$('.answer textarea')
            text.textSaver()
            @$('.answer').click() unless text.val() is ""

        @model.forEach (comment) =>
            entry = @views[comment.cid]
            entry.render()
            @el.prepend entry.el

    update_attributes: ->
        @user = @parent.parent.parent.user # topicpostview.postsview.channelview

