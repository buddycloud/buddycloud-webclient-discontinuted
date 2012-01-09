{ BaseView } = require '../base'
{ PostsView } = require './posts'
{ EventHandler } = require '../../util'


class exports.ChannelView extends BaseView
    template: require '../../templates/channel/index'

    events:
        'click .follow': 'clickFollow'
        'click .unfollow': 'clickUnfollow'
        'click .newTopic, .answer': 'openNewTopicEdit'
        'click #createNewTopic': 'clickPost'
        'scroll': 'on_scroll'

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

    render: (callback) ->
        super ->
            @rendered = yes
            if @model
                text = @$('.newTopic textarea')
                text.textSaver()
                text.autoResize
                    extraSpace:0
                    animate:off
                @$('.newTopic').click() unless text.val() is ""

            unless @hidden
                @el.show()
                @on_scroll()

            pending = 0
            if @details?
                pending++
                @details.render =>
                    @trigger 'subview:details', @details.el
                    callback?.call(this) unless --pending
            if @postsview?
                pending++
                @postsview.render =>
                    @trigger 'subview:topics', @postsview.el
                    @on_scroll() unless @hidden
                    callback?.call(this) unless --pending
            unless pending
                callback?.call(this)

    # create posts node view when it arrives from xmpp or instant when its already cached
    init_posts: =>
        @model.nodes.unbind "add", @init_posts
        if (postsnode = @model.nodes.get 'posts')
            if (title = postsnode.metadata.get('title')?.value)
                @trigger('view:title', title)
            @postsview = new PostsView
                model: postsnode
                parent: this
            # To display posts node errors:
            postsnode.bind 'error', @set_error
            @set_error postsnode.error
            if @rendered
                @postsview.render =>
                    @trigger 'subview:topics', @postsview.el
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

    clickFollow: EventHandler (ev) ->
        @$('.follow').remove()
        @set_error null

        app.handler.data.subscribe_user @model.get('id'), (error) =>
            if error
                @set_error error
#             @render() FIXME

    clickUnfollow: EventHandler (ev) ->
        @$('.unfollow').remove()
        @set_error null

        app.handler.data.unsubscribe_user @model.get('id'), (error) =>
            if error
                @set_error error
#             @render() FIXME

    # InfiniteScrolling™ when reaching the bottom
    on_scroll: ->
        if @el.scrollTop() >= @$('.stream').innerHeight() - @el.outerHeight() * 1.1
            @on_scroll_bottom()

    on_scroll_bottom: ->
        @postsview?.on_scroll_bottom()

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
