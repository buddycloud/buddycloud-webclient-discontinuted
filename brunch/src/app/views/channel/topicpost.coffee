{ CommentsView } = require 'views/channel/comments'
{ PostView } = require 'views/channel/post'

class exports.TopicPostView extends Backbone.View
    template: require 'templates/channel/topicpost'

    initialize: ({@parent}) ->
        @el = $("<div>").attr id:@cid
        @opener   = new PostView model:@model, parent:this
        @comments = new CommentsView model:@model.comments, parent:this
        @el.append @opener.el
        @el.append @comments.el


    render: =>
        old = @el; old.replaceWith @el = $(@template this).attr id:@cid
        @el.append @opener.el
        @el.append @comments.el
        do @opener.render
        do @comments.render

