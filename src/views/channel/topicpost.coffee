{ parallel } = require 'async'
{ CommentsView } = require './comments'
{ PostView } = require './post'
{ BaseView } = require '../base'
{ gravatar } = require '../../../util'

class exports.TopicPostView extends BaseView

    template: require '../../templates/channel/topicpost'
    
    events:
        'keyup .answer textarea': 'keypress'

    initialize: ->
        @hidden = no
        super
        @model.on('change:author', @on_author)
        @opener   = new PostView
            type:'opener'
            model:@model
            parent:this

        @comments = new CommentsView
            model:@model.comments
            parent:this

    getChannel: () ->
        @parent.getChannel()

    on_author: =>
        if @model.get('author')?.jid?
            # Show only openers with content
            @hidden = no
            @el?.show()
        else
            # Do not yet show openers that were automatically created
            # for an early-received comment
            @hidden = yes
            @el?.hide()

    render: (callback) ->
        @rendering = yes
        if @model.get('content')?.value?.indexOf?("Waiting for the ") is 0
            console.error "##############", @cid, this
        @domready @setupInlineMention
        super ->
            @rendering = no
            parallel [((n)->n())
            ,(_..., next) =>
                @opener.render(next)
            ,(_..., next) =>
                @comments.render(next)
            ],(err) =>
                callback?.call(this)

            if @hidden
                @el?.hide()
            else
                @el?.show()

    keypress: (ev) ->
     if !@autocomplete?
       @setupInlineMention()
     if ev.which is 16
       if @autocomplete.disabled is false
         @autocomplete.enable()
       return
     # Escape, tab, enter, up, down
     if ev.which in [27, 9, 13, 9]
       @autocomplete.disable()
       return

    setupInlineMention: ->
     followers = []
     @parent.parent.details.followers.model.forEach (user) ->
       uid = user.get 'id'
       followers.push user.attributes.jid
      
     @autocomplete = @$('textarea').autocomplete(
           lookup: followers
           dataKey: 'jid',
           delimiter: ' ',
           minChars: 1,
           zIndex: 9999,
           searchPrefix: '@',
           noCache: true
     )
     suggestions = @autocomplete.options.lookup.suggestions
     @parent.parent.details.followers.bind('add', (user) ->
       jid = user.get('jid')
       suggestions.push {jid: jid, gravatar: "#{gavatar jid}"}
     )
     @parent.parent.details.followers.bind('remove', (user) ->
       jid = user.get('jid')
       suggestions = suggestions.filter (user) -> user.jid isnt "#{jid}"
     )
