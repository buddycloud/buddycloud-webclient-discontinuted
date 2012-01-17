{ CommentsView } = require './comments'
{ PostView } = require './post'
{ BaseView } = require '../base'

class exports.TopicPostView extends BaseView
    template: require '../../templates/channel/topicpost'

    initialize: ->
        @hidden = no
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
            @hidden = no
            @el.show()
        else
            # Do not yet show openers that were automatically created
            # for an early-received comment
            @hidden = yes
            @el.hide()

    render: (callback) ->
        super ->
            pending = 2
            @opener.render =>
                @trigger 'subview:opener', @opener.el
                callback?.call(this) unless --pending
            @comments.render =>
                @trigger 'subview:comments', @comments.el
                callback?.call(this) unless --pending

            if @hidden
                @el.hide()
            else
                @el.show()

            callback?.call(this) unless pending
