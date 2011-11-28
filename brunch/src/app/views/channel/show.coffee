{ ChannelDetails } = require 'views/channel/details/show'
{ PostsView } = require 'views/channel/posts'
{ ErrorNotificationView } = require 'views/channel/error_notification'
{ BaseView } = require 'views/base'
{ EventHandler, throttle_callback } = require 'util'

# The channel shows channel content
class exports.ChannelView extends BaseView
    template: require 'templates/channel/show'

    initialize: ->
        super

        @bind 'show', @show
        @bind 'hide', @hide

        @details = new ChannelDetails model:@model, parent:this

        render_callback = throttle_callback(50, @render)
        @model.bind 'change', render_callback
        @model.bind 'change:node:metadata', render_callback
        app.users.current.channels.bind "add:#{@model.get 'id'}", render_callback
        app.users.current.channels.bind "remove:#{@model.get 'id'}", render_callback

        # New post, visible? Mark read.
        @model.bind 'post', =>
            unless @hidden
                @model.mark_read()

        # Show progress spinner throbber loader
        @model.bind 'loading:start', @render
        @model.bind 'loading:stop', @render
        app.handler.data.bind 'loading:start', @render
        app.handler.data.bind 'loading:stop', @render

        # create posts node view when it arrives from xmpp or instant when its already cached
        init_posts = =>
            @model.nodes.unbind "add", init_posts
            if (postsnode = @model.nodes.get 'posts')
                @postsview = new PostsView
                    model: postsnode
                    parent: this
                    el: @el.find('.topics')
                # To display posts node errors:
                postsnode.bind 'error', @set_error
                @set_error postsnode.error

                do @postsview.render
                do @render
            else
                @model.nodes.bind "add", init_posts
        do init_posts

    show: =>
        @hidden = false
        @el.show()

        @model.mark_read()
        # Not subscribed? Refresh!
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
            app.handler.data.publish node, post, (error) =>
                # TODO: make sure prematurely added post
                # correlates to incoming notification
                # (in comments.coffee too)
                #post.content = value:post.content
                #app.handler.data.add_post node, post

                # Re-enable form
                text.removeAttr "disabled"
                @isPosting = false
                unless error
                    # Reset form
                    @el.find('.newTopic').removeClass 'write'
                    text.val ""
                    text.keyup() # clear localstorage
                else
                    console.error "postError", error
                    @show_post_error error

    # error display in .newTopic .controls
    show_post_error: (error) =>
        p = $('<p class="postError"></p>')
        @$('.newTopic .controls').prepend(p)
        p.text(error.text or error.condition)

    set_error: (error) =>
        if error
            unless @error_notification
                @error_notification = new ErrorNotificationView({ error })
            else
                @error_notification.error = error
        else
            delete @error_notification
        @render()

    openNewTopicEdit: EventHandler (ev) ->
        ev.stopPropagation()

        self = @$('.newTopic, .answer').has(ev.target)
        self = $(ev.target) unless self.length
        text = self.find('textarea')

        unless self.hasClass 'write' or text.val() is ""
            self.addClass 'write'
            $(document).click on_click = ->
                # minimize the textarea only if the textarea is empty
                if text.val() is ""
                    self.removeClass 'write'
                    $(document).unbind 'click', on_click

    clickFollow: EventHandler (ev) ->
        @$('.follow').remove()
        @set_error null

        app.handler.data.subscribe_user @model.get('id'), (error) =>
            if error
                @set_error error
            @render()

    clickUnfollow: EventHandler (ev) ->
        @$('.unfollow').remove()
        @set_error null

        app.handler.data.unsubscribe_user @model.get('id'), (error) =>
            if error
                @set_error error
            @render()

    on_scroll_bottom: ->
        @postsview?.on_scroll_bottom()

    render: =>
        @update_attributes()
        super

        if @model
            text = @$('.newTopic textarea')
            text.textSaver()
            @$('.newTopic').click() unless text.val() is ""

        if @hidden
            @el.hide()
        do @details.render
        @el.append @details.el

        if @error_notification
            @error_notification.render()
            @$('.stream').prepend @error_notification.el
        if @postsview
            # TODO: save form content?
            @$('.topics').replaceWith @postsview.el
            @postsview.render()

    update_attributes: ->
        if (postsNode = @model.nodes.get 'posts')
            # @error is also set by clickFollow() & clickUnfollow()
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
        @isLoading = @model.isLoading or app.handler.data.isLoading
