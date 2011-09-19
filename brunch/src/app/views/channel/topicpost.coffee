{ CommentsView } = require 'views/channel/comments'
{ PostView } = require 'views/channel/post'
{ BaseView } = require('views/base')

class exports.TopicPostView extends BaseView
    template: require 'templates/channel/topicpost'

    initialize: ->
        super
        @opener   = new PostView model:@model, parent:this
        @comments = new CommentsView model:@model.comments, parent:this
        @el.append @opener.el
        @el.append @comments.el


    render: =>
        super
        @el.append @opener.el
        @el.append @comments.el
        do @opener.render
        do @comments.render

