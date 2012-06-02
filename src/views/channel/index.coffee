{ BaseView } = require '../base'
{ PostsView } = require './posts'
{ ChannelDetailsView } = require './details/index'
{ ChannelEditView } = require './edit'
{ ErrorNotificationView } = require './error_notification'
{ FollowNotificationView } = require './follow_notification'
{ PendingNotificationView } = require './pending_notification'
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
        'click .save': 'clickSave'

    initialize: () ->
        super

        @bind 'show', @show
        @bind 'hide', @hide

        postsnode = @model.nodes.get_or_create(id:'posts')
        @postsview = new PostsView
            model: postsnode
            parent: this
        # To display posts node errors:
        postsnode.bind 'error', @set_error
        @set_error postsnode.error if postsnode.error
#
        # New post, visible? Mark read.
        @model.bind 'post', =>
            unless @hidden
                @model.mark_read()

        # Potentially expensive (filters all node affiliations)
        trigger_update_permissions = throttle_callback 50, =>
            @trigger 'update:permissions'
        show_follow_notifications_callback = throttle_callback 100, @show_follow_notifications
        show_pending_notification_callback = throttle_callback 100, @show_pending_notification

        postsnode.bind 'subscriber:update', (subscriber) =>
            trigger_update_permissions()
            show_follow_notifications_callback()
            show_pending_notification_callback()
        postsnode.bind 'affiliation:update', =>
            @trigger 'update:affiliations'
            trigger_update_permissions()
            show_follow_notifications_callback()
        postsnode.metadata.bind 'change', =>
            @trigger 'update:metadata'
            trigger_update_permissions()
            show_follow_notifications_callback()
            # Special handling for a publish_model that is based on
            # subscription state not affiliation: (actually we should
            # have this data already because we fetch our own
            # /subscriptions node first, do we?)
            if postsnode.metadata.get('publish_model')?.value is 'subscribers'
                app.handler.data.get_all_node_subscriptions postsnode.get('nodeid')
        postsnode.bind 'unsync', =>
            @set_error null
            @on_scroll()


        # Retrieve status text and send to view
        statusnode = @model.nodes.get_or_create(id:'status')
        statusnode.bind 'post', @update_status

        @details = new ChannelDetailsView
            model: @model
            parent: this

        @follow_notification_views = {}

    render: (callback) ->
        node = @model.nodes.get_or_create id: 'posts'
        @metadata = node.metadata
        unless node.metadata_synced
            app.handler.data.get_node_metadata node.get('nodeid')
        app.handler.data.get_all_node_affiliations node.get('nodeid')

        super ->
            if @model
                text = @$('.newTopic textarea')
                text.textSaver()
                @$('.newTopic').click() unless text.val() is ""

                @update_status()

            @postsview.render =>
                @on_scroll() unless @hidden
            @details.render()

            @show_follow_notifications()
            @show_pending_notification()

            unless @hidden
                @trigger 'show'
                @on_scroll()

            callback?.call(this)

#             pending = 0 # FIXME add details
#             if @details?
#                 pending++
#                 @details.render =>
#                     @trigger 'subview:details', @details.el
#                     callback?.call(this) unless --pending
#             unless pending

    show: =>
        @hidden = false

        @model.mark_read() unless @rendered

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
            post = @postsview.createPost(content:text.val())
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
                    @$('.newTopic').removeClass 'write'
                    text.val ""
                    # clear localStorage
                    text.trigger 'txtinput'
                else
                    console.error "postError", error
                    @show_post_error error

    clickLogin: EventHandler (ev) ->
        # Just make this work for now
        app.router.navigate "login", true
        return
        # TODO: implement the overlay login below and graceful
        # replacement of the Strophe session & registration!
        @overlay ?= new OverlayLogin()
        @overlay.show()

    clickFollow: EventHandler (ev) ->
        @$('.follow').hide()
        @set_error null

        app.handler.data.subscribe_user @model.get('id'), (error) =>
            if error
                @set_error error

    clickUnfollow: EventHandler (ev) ->
        @$('.unfollow').hide()
        @set_error null

        app.handler.data.unsubscribe_user @model.get('id'), (error) =>
            if error
                @set_error error
            @$('.follow').show()

    update_status: =>
        statusnode = @model.nodes.get_or_create(id:'status')
        value = statusnode.posts.at(0)?.get('content')?.value
        console.warn @model.get('id'), statusnode, "update_status", value
        if value
            @trigger('status', value)
        else
            @load_status_posts()

    load_status_posts: =>
        statusnode = @model.nodes.get_or_create(id:'status')
        # FIXME: when we're anonymous, refresh_channel() gets those
        # for us already!
        app.handler.data.get_node_posts(statusnode)

    # InfiniteScrolling™ when reaching the bottom
    on_scroll: throttle_callback(100, ->
        return unless @rendered
        if this is @parent.current
            peepholeTop = @$el.scrollTop()
            peepholeBottom = peepholeTop + @$el.outerHeight()
            @postsview?.on_scroll(peepholeTop, peepholeBottom)
    )

    set_error: (error) =>
        if @error_view?
            @error_view.remove()
            delete @error_view

        if error?
            @error_view = new ErrorNotificationView
                parent:this
                error:error
            @ready =>
                @error_view.bind 'template:create', (tpl) =>
                    @trigger 'subview:notification', tpl
                @error_view.render()

    clickEdit: EventHandler ->
        unless @editview
            @editview = new ChannelEditView { parent: this, @model }
            @editview.bind 'template:create', (tpl) =>
                @parent.trigger('subview:editbar', tpl)
            @editview.render()
        @editview.toggle()
        
    clickSave: EventHandler ->
#        unless @editview
#            @editview = new ChannelEditView { parent: this, @model }
#            @editview.bind 'template:create', (tpl) =>
#                @parent.trigger('subview:editbar', tpl)
#            @editview.render()
        @editview.clickSave()

    isEditing: =>
        @editview?.active

    show_follow_notifications: =>
        if app.users.current.canModerate @model.get('id')
            # User is owner/moderator and may approve follow notifications
            postsnode = app.channels.get(@model.get 'id')?.
                nodes.get_or_create(id: 'posts')

            postsnode.subscribers.forEach (subscriber) =>
                jid = subscriber.get 'id'
                if subscriber.get('subscription') is 'pending' and
                   not @follow_notification_views.hasOwnProperty(jid)
                    # Add new view
                    view = new FollowNotificationView(parent: this, model: subscriber)
                    @follow_notification_views[jid] = view
                    @ready =>
                        view.bind 'template:create', (tpl) =>
                            @trigger 'subview:notification', tpl
                        view.render()

                else if @follow_notification_views.hasOwnProperty(jid) and
                        subscriber.get('subscription') isnt 'pending'
                    # Remove old view (or update to current state)
                    @follow_notification_views[jid].remove()
                    delete @follow_notification_views[jid]

        else
            # May (suddenly) not approve followers, remove all previous views:
            for own userid, view of @follow_notification_views
                view.remove()
            @follow_notification_views = {}

    show_pending_notification: =>
        subscription = app.users.current.getSubscriptionFor @model
        if subscription is 'pending' and
           not @pending_notification?
            @pending_notification = new PendingNotificationView(parent: this)
            @pending_notification.bind 'template:create', (tpl) =>
                @trigger 'subview:notification', tpl
            @pending_notification.render()
        else if subscription isnt 'pending' and
                @pending_notification?
            @pending_notification.remove()
            delete @pending_notification
