{ CommentsView } = require 'views/channel/comments'
{ PostView } = require 'views/channel/post'
{ BaseView } = require 'views/base'

class exports.TopicPostView extends BaseView
    template: require 'templates/channel/topicpost'

    initialize: ({@parent}) ->
        super
        @opener   = new PostView type:'opener', model:@model, parent:this
        @comments = new CommentsView model:@model.comments, parent:this
        @el.append @opener.el
        @el.append @comments.el


    render: =>
        super
        do @opener.render
        do @comments.render
        @el.append @opener.el
        @el.append @comments.el

