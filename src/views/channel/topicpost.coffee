{ CommentsView } = require './comments'
{ PostView } = require './post'
{ BaseView } = require '../base'

class exports.TopicPostView extends BaseView
    template: require '../../templates/channel/topicpost'

    initialize: ->
        super
#         @model.bind 'change', @render FIXME
        @model.bind 'change:author', @on_author

        @opener   = new PostView
            type:'opener'
            model:@model
            parent:this

        @comments = new CommentsView
            model:@model.comments
            parent:this

    on_author: =>
        if @model.get('author')?.jid?
            # Show only openers with content
            @el.show()
        else
            # Do not yet show openers that were automatically created
            # for an early-received comment
            @el.hide()

    render: (callback) ->
        super ->
            pending = 2
            @rendered = yes
            @opener.render =>
                @trigger 'subview:opener', @opener.el
                callback?.call(this) unless --pending
            @comments.render =>
                @trigger 'subview:comments', @comments.el
                callback?.call(this) unless --pending

            callback?.call(this) unless pending
