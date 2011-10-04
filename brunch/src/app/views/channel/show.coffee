{ ChannelDetails } = require 'views/channel/details/show'
{ PostsView } = require 'views/channel/posts'
{ BaseView } = require 'views/base'
{ EventHandler } = require 'util'

# The channel shows channel content
class exports.ChannelView extends BaseView
    template: require 'templates/channel/show'

    initialize: ->
        super
        @details = new ChannelDetails model:@model, parent:this

        @model.bind 'change', @render
        @model.bind 'change:node:metadata', @render
        app.users.current.channels.bind "add", @render
        app.users.current.channels.bind "remove", @render
        # create posts node view when it arrives from xmpp or instant when its already cached
        init_posts = =>
            @model.nodes.unbind "add", init_posts
            if (postsnode = @model.nodes.get 'posts')
                @postsview = new PostsView
                    model: postsnode
                    parent: this
                    el: @el.find('.topics')
                do @postsview.render
                do @render
            else
                @model.nodes.bind "add", init_posts
        do init_posts

    events:
        'click .follow': 'clickFollow'
        'click .unfollow': 'clickUnfollow'
        'click .newTopic, .answer': 'openNewTopicEdit'
        'click #createNewTopic': 'clickPost'

    clickPost: EventHandler (ev) ->
        if @isPosting
            return
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
                    post.content = value:post.content
                    # TODO: make sure prematurely added post correlates to incoming notification
                    #app.handler.data.add_post node, post
                    @el.find('.newTopic, .answer').removeClass 'write'
                    text.val ""
                    text.removeAttr "disabled"
                    @isPosting = false

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
        do @details.render
        @el.append @details.el

        if @postsview
            # TODO: save form content?
            @el.find('.topics').replaceWith @postsview.el
            do @postsview.render

    update_attributes: ->
        if (channel = @model.nodes.get 'posts')
            @channel = channel.toJSON yes
        if (geo = @model.nodes.get 'geo')
            @geo = geo.toJSON yes
        # Permissions:
        followingThisChannel = app.users.current.channels.get(channel?.get 'nodeid')?
        #affiliation = app.users.current.affiliations.get(@model.nodes.get('posts')?.get 'nodeid') or "none"
        # TODO: pending may require special handling
        @user =
            followingThisChannel: followingThisChannel
            hasRightToPost: yes #affiliation in ["owner", "publisher", "moderator", "member"]
