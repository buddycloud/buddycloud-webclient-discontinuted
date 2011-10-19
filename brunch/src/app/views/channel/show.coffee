{ ChannelDetails } = require 'views/channel/details/show'
{ PostsView } = require 'views/channel/posts'
{ BaseView } = require 'views/base'
{ EventHandler } = require 'util'

# The channel shows channel content
class exports.ChannelView extends BaseView
    template: require 'templates/channel/show'

    initialize: ->
        super

        @bind 'show', @show
        @bind 'hide', @hide

        @details = new ChannelDetails model:@model, parent:this

        @model.bind 'change', @render
        @model.bind 'change:node:metadata', @render
        app.users.current.channels.bind "add:#{@model.get 'id'}", @render
        app.users.current.channels.bind "remove:#{@model.get 'id'}", @render
        # create posts node view when it arrives from xmpp or instant when its already cached
        init_posts = =>
            @model.nodes.unbind "add", init_posts
            if (postsnode = @model.nodes.get 'posts')
                @postsview = new PostsView
                    model: postsnode
                    parent: this
                    el: @el.find('.topics')
                do @postsview.render
                # To display posts node errors:
                postsnode.bind 'change', =>
                    console.log "postsnode change", arguments...
                    @render()
                do @render
            else
                @model.nodes.bind "add", init_posts
        do init_posts

    show: =>
        @hidden = false
        @el.show()

        unless app.users.current.channels.get(@model.get 'id')?
            app.handler.data.refresh_channel(@model.get 'id')

    hide: =>
        @hidden = true
        @el.hide()

    events:
        'click .follow': 'clickFollow'
        'click .unfollow': 'clickUnfollow'
        'click .newTopic, .answer': 'openNewTopicEdit'
        'click #createNewTopic': 'clickPost'

    clickPost: EventHandler (ev) ->
        if @isPosting
            return
        @$('.newTopic .postError').remove()
        self = @$('.newTopic').has(ev.target)
        text = self.find('textarea')
        unless text.val() is ""
            text.attr "disabled", "disabled"
            @isPosting = true
            post =
                content: text.val()
                author:
                    name: app.users.current.get 'jid'
            node = @model.nodes.get('posts')
            app.handler.data.publish node, post, =>
                # TODO: make sure prematurely added post
                # correlates to incoming notification
                # (in comments.coffee too)
                #post.content = value:post.content
                #app.handler.data.add_post node, post

                # Re-enable form
                text.removeAttr "disabled"
                @isPosting = false
                # Reset form
                @el.find('.newTopic, .answer').removeClass 'write'
                text.val ""
            , (e) =>
                console.error "postError", e
                # Re-enable form
                text.removeAttr "disabled"
                @isPosting = false
                # Show error
                @$('.newTopic .controls').prepend('<p class="postError"></p>')
                @$('.newTopic .postError').text(e.text or e.condition)

    openNewTopicEdit: EventHandler (ev) ->
        ev.stopPropagation()

        self = @$('.newTopic, .answer').has(ev.target)
        unless self.hasClass 'write'
            self.addClass 'write'
            $(document).one 'click', ->
                # minimize the textarea only if the textarea is empty
                if self.find('textarea').val() is ""
                    self.removeClass 'write'

    clickFollow: EventHandler (ev) ->
        app.handler.data.subscribeUser @model.get('id')

    clickUnfollow: EventHandler (ev) ->
        app.handler.data.unsubscribeUser @model.get('id')

    render: =>
        @update_attributes()
        super

        if @hidden
            @el.hide()
        do @details.render
        @el.append @details.el

        if @postsview
            # TODO: save form content?
            @el.find('.topics').replaceWith @postsview.el
            do @postsview.render

        setTimeout =>
            @$('.notification').addClass 'visible'
        , 1

    update_attributes: ->
        if (postsNode = @model.nodes.get 'posts')
            @error = postsNode.get 'error'
            console.warn "ChannelView.update_attributes", @error
            @postsNode = postsNode.toJSON yes
        if (geo = @model.nodes.get 'geo')
            @geo = geo.toJSON yes
        # Permissions:
        followingThisChannel = app.users.current.channels.get(postsNode?.get 'nodeid')?
        #affiliation = app.users.current.affiliations.get(@model.nodes.get('posts')?.get 'nodeid') or "none"
        isAnonymous = app.users.current.get('id') is 'anony@mous'
        # TODO: pending may require special handling
        @user =
            followingThisChannel: followingThisChannel
            hasRightToPost: not isAnonymous # affiliation in ["owner", "publisher", "moderator", "member"]
            isAnonymous: isAnonymous
