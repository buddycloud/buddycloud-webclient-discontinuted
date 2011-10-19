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
        @$('.newTopic .postError').remove()
        text = @$('textarea')
        unless text.val() is ""
            text.attr "disabled", "disabled"
            @isPosting = true
            post =
                content: text.val()
                author:
                    name: app.users.current.get 'jid'
                in_reply_to: @model.parent.id
            node = @model.parent.collection.parent
            app.handler.data.publish node, post, =>
                # Re-enable form
                @el.find('.newTopic').removeClass 'write'
                @isPosting = false
                text.removeAttr "disabled"
                # Reset form
                text.val ""
            , (e) =>
                # Re-enable form
                @el.find('.newTopic').removeClass 'write'
                @isPosting = false
                text.removeAttr "disabled"
                # Show error
                @$('.newTopic .controls').prepend('<p class="postError"></p>')
                @$('.newTopic .postError').text(e.text or e.condition)

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
        @model.forEach (comment) =>
            entry = @views[comment.cid]
            entry.render()
            @el.prepend entry.el

    update_attributes: ->
        @user = @parent.parent.parent.user # topicpostview.postsview.channelview

