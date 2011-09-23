{ BaseView } = require 'views/base'
{ PostView } = require 'views/channel/post'

class exports.CommentsView extends BaseView
    template: require 'templates/channel/comments'

    initialize: ({@parent}) ->
        super
        @views = {}
        @model.bind 'change', @render
        @model.forEach @add_comment
        @model.bind 'add', @add_comment

    add_comment: (comment) =>
        entry = @views[comment.cid] ?= new PostView
            type:'comment'
            model:comment
            parent:this

        i = @model.indexOf(comment)
        olderComment = @views[@model.at(i + 1)?.cid]
        if olderComment
            olderComment.el.before entry.el
        else
            @el.prepend entry.el
        do entry.render

    render: =>
        @update_attributes()
        super
        for cid, entry of @views
            entry.render()

    update_attributes: ->
        @user = @parent.parent.parent.user # topicpostview.postsview.channelview

