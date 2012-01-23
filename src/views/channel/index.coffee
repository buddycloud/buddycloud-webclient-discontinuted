{ BaseView } = require '../base'
{ PostsView } = require './posts'
{ ChannelDetailsView } = require './details/index'
{ ChannelEditView } = require './edit'
{ OverlayLogin } = require '../authentication/overlay'
{ EventHandler, throttle_callback } = require '../../util'


class exports.ChannelView extends BaseView
    template: require '../../templates/channel/index'

    events:
        'click .login': 'clickLogin'
        'click .follow': 'clickFollow'
        'click .unfollow': 'clickUnfollow'
        'click .newTopic, .answer': 'openNewTopicEdit'
        'keydown .newTopic textarea': 'hitEnterOnPost'
        'click #createNewTopic': 'clickPost'
        'scroll': 'on_scroll'
        'click .edit': 'clickEdit'

    initialize: () ->
        super

        @bind 'show', @show
        @bind 'hide', @hide

        do @init_posts
#         @model.bind 'change', render_callback
#         @model.bind 'change:node:metadata', render_callback
#         app.users.current.channels.bind "add:#{@model.get 'id'}", render_callback
#         app.users.current.channels.bind "remove:#{@model.get 'id'}", render_callback
#
        # New post, visible? Mark read.
        @model.bind 'post', =>
            unless @hidden
                @model.mark_read()
#
#         # Show progress spinner throbber loader
#         @model.bind 'loading:start', @on_loading_start
#         @model.bind 'loading:stop', @on_loading_stop
#         app.handler.data.bind 'loading:start', @on_loading_start
#         app.handler.data.bind 'loading:stop', @on_loading_stop

        @details = new ChannelDetailsView
            model: @model
            parent: this

    render: (callback) ->
        node = @model.nodes.get_or_create id: 'posts'
        @metadata = node.metadata
        unless node.metadata_synced
            app.handler.data.get_node_metadata node.get('nodeid')

        super ->
            if @model
                text = @$('.newTopic textarea')
                text.textSaver()
                text.autoResize
                    extraSpace:0
                    animate:off
                @$('.newTopic').click() unless text.val() is ""

            @details.render =>
                @trigger 'subview:details', @details.el

            unless @hidden
                @el.show()
                @on_scroll()

            callback?.call(this)

#             pending = 0 # FIXME add details
#             if @details?
#                 pending++
#                 @details.render =>
#                     @trigger 'subview:details', @details.el
#                     callback?.call(this) unless --pending
#             unless pending

    # create posts node view when it arrives from xmpp or instant when its already cached
    init_posts: =>
        @model.nodes.unbind "add", @init_posts
        if (postsnode = @model.nodes.get 'posts')
            @postsview = new PostsView
                model: postsnode
                parent: this
            # To display posts node errors:
            postsnode.bind 'error', @set_error
            @set_error postsnode.error
            @postsview.render =>
                @ready =>
                    @trigger 'subview:topics', @postsview.el
                    @on_scroll() unless @hidden
        else
            @model.nodes.bind "add", @init_posts

    show: =>
        @hidden = false
        @el.show()

        @model.mark_read()
        # Not subscribed? Refresh!
        unless app.users.current.isFollowing(@model)
            app.handler.data.refresh_channel(@model.get 'id')

        # when scrolled to the bottom, cause loading of more posts via
        # RSM because we are showing too few of them.
        #
        # example: so far only retrieved comments to an older post
        # which are all hidden, because that parent post is on a
        # further RSM page.
        @on_scroll()

    hide: =>
        @hidden = true
        @el.hide()

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

    hitEnterOnPost: (ev) ->
        code = ev.keyCode or ev.which
        if code is 13 and ev.ctrlKey # CTRL + Enter
            ev?.preventDefault?()
            @clickPost(ev)
            return false
        return true

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
                    # clear localStorage
                    text.trigger 'txtinput'
                else
                    console.error "postError", error
                    @show_post_error error

    clickLogin: EventHandler (ev) ->
        @overlay ?= new OverlayLogin()
        @overlay.show()

    clickFollow: EventHandler (ev) ->
        @$('.follow').hide()
        @set_error null

        app.handler.data.subscribe_user @model.get('id'), (error) =>
            if error
                @set_error error
#             @render() FIXME

    clickUnfollow: EventHandler (ev) ->
        @$('.unfollow').hide()
        @set_error null

        app.handler.data.unsubscribe_user @model.get('id'), (error) =>
            if error
                @set_error error
#             @render() FIXME

    # InfiniteScrolling™ when reaching the bottom
    on_scroll: throttle_callback(100, ->
        if this is @parent.current
            peepholeTop = @el.scrollTop()
            peepholeBottom = peepholeTop + @el.outerHeight()
            @postsview?.on_scroll(peepholeTop, peepholeBottom)
    )

    set_error: (error) =>
#         if error
#             unless @error_notification
#                 @error_notification = new ErrorNotificationView({ error })
#             else
#                 @error_notification.error = error
#         else
#             delete @error_notification
#         @render() FIXME

#     update_attributes: ->
#         if (postsNode = @model.nodes.get 'posts')
#             # @error is also set by clickFollow() & clickUnfollow()
#             @postsNode = postsNode.toJSON yes
#         if (geo = @model.nodes.get 'geo')
#             @geo = geo.toJSON yes
#         # Permissions:
#         followingThisChannel = app.users.current.channels.get(postsNode?.get 'nodeid')?
#         #affiliation = app.users.current.affiliations.get(@model.nodes.get('posts')?.get 'nodeid') or "none"
#         isAnonymous = app.users.current.get('id') is 'anony@mous'
#         # TODO: pending may require special handling
#         @user =
#             isCurrent: @model.get('id') is app.users.current.get('id')
#             followingThisChannel: followingThisChannel
#             hasRightToPost: not isAnonymous # affiliation in ["owner", "publisher", "moderator", "member"]
#             isAnonymous: isAnonymous
#         @isLoading = @model.isLoading or app.handler.data.isLoading

    clickEdit: EventHandler ->
        @$('.edit').hide()
        editview = new ChannelEditView({ @parent, @model })
        editview.render =>
            @parent.trigger 'subview:editbar', editview.el
        editview.bind 'end', =>
            @$('.edit').show()
