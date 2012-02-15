{ BaseView } = require '../base'
{ PostsView } = require './posts'
{ ChannelDetailsView } = require './details/index'
{ ChannelEditView } = require './edit'
{ ErrorNotificationView } = require './error_notification'
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

        postsnode = @model.nodes.get_or_create(id:'posts')
        @postsview = new PostsView
            model: postsnode
            parent: this
        # To display posts node errors:
        postsnode.bind 'error', @set_error
        @set_error postsnode.error if postsnode.error
        @postsview.render =>
            @ready =>
                @trigger 'subview:topics', @postsview.el
                @on_scroll() unless @hidden
#
        # New post, visible? Mark read.
        @model.bind 'post', =>
            unless @hidden
                @model.mark_read()
        postsnode.bind 'affiliation:update', =>
            @trigger 'update:affiliations'
        postsnode.metadata.bind 'update', =>
            @trigger 'update:metadata'
            # Special handling for a publish_model that is based on
            # subscription state not affiliation:
            if postsnode.metadata.get('publish_model')?.value is 'subscribers'
                app.handler.data.get_all_node_subscriptions node.get('nodeid')

        # Retrieve status text and send to view
        statusnode = @model.nodes.get_or_create(id:'status')
        statusnode.bind 'post', @update_status

        @details = new ChannelDetailsView
            model: @model
            parent: this

    render: (callback) ->
        node = @model.nodes.get_or_create id: 'posts'
        @metadata = node.metadata
        unless node.metadata_synced
            app.handler.data.get_node_metadata node.get('nodeid')
        unless app.users.isAnonymous(app.users.current)
            app.handler.data.get_all_node_affiliations node.get('nodeid')

        super ->
            if @model
                text = @$('.newTopic textarea')
                text.textSaver()
                text.autoResize
                    extraSpace:0
                    animate:off
                @$('.newTopic').click() unless text.val() is ""

                @update_status()

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
        # Just make this work for now
        window.location = "/login"
        return
        # TODO: implement the overlay login below and graceful
        # replacement of the Strophe session

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
            @$('.follow').show()
#             @render() FIXME

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
        if this is @parent.current
            peepholeTop = @el.scrollTop()
            peepholeBottom = peepholeTop + @el.outerHeight()
            @postsview?.on_scroll(peepholeTop, peepholeBottom)
    )

    set_error: (error) =>
        return unless error
        console.warn "set_error", error
        view = new ErrorNotificationView
            parent:this
            error:error
        @ready =>
            view.render =>
                @trigger('subview:notification', view.el)

    clickEdit: EventHandler ->
        unless @editview
            @editview = new ChannelEditView { parent: this, @model }
            @editview.bind 'update:el', (el) =>
                @parent.trigger('subview:editbar', el)
        @editview.toggle()

    isEditing: =>
        @editview?.active
