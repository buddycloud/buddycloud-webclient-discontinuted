{ ChannelDetails } = require 'views/channel/details/show'
{ PostsView } = require 'views/channel/posts'
{ BaseView } = require('views/base')

# The channel shows channel content
class exports.ChannelView extends BaseView
    template: require 'templates/channel/show'

    initialize: ->
        super
        @details = new ChannelDetails model:@model, parent:this

        @model.bind 'change', @render
        @model.bind 'change:node:metadata', @render
        # create posts node view when it arrives from xmpp or instant when its already cached
        init_posts = =>
            @model.nodes.unbind "add", init_posts
            if (postsnode = @model.nodes.get 'posts')
                @postsview = new PostsView
                    model:postsnode
                    parent:this
                    el:@el.find('.topics')
                do @postsview.render
            else
                @model.nodes.bind "add", init_posts
        do init_posts

    render: =>
        @update_attributes()
        super
        do @details.render
        @el.append @details.el

        if @postsview
            # TODO: save form content?
            @el.find('.topics').replaceWith @postsview.el
            do @postsview.render
        @el.find('.newTopic, .answer').click @openNewTopicEdit

        $('#createNewTopic').click =>
            text = @el.find('.newTopic, .answer').find('textarea')
            unless text.val() is ""
                post =
                    content: text.val()
                    author:
                        name: app.users.current.get 'jid'
                node = @model.nodes.get('posts')
                app.handler.data.publish node, post, =>
                        post.content = value:post.content
                        app.handler.data.add_post node, post
                        @el.find('.newTopic, .answer').removeClass 'write'
                        text.val ""
        @$('.follow').click (ev) =>
            ev.preventDefault()
            node = @model.nodes.get('posts')
            app.handler.data.subscribe node
            false
        @$('.unfollow').click (ev) =>
            ev.preventDefault()
            node = @model.nodes.get('posts')
            app.handler.data.unsubscribe node
            false

    openNewTopicEdit: (ev) ->
        self = $(this) # @el.find('.newTopic, .answer')
        # prevent bubbling!
        ev.stopPropagation()
        unless self.hasClass 'write'
            self.addClass 'write'
            $(document).one 'click', ->
                # minimize the textarea only if the textarea is empty
                if self.find('textarea').val() is ""
                    self.removeClass 'write'

    update_attributes: ->
        if (channel = @model.nodes.get 'posts')
            @channel = channel.toJSON yes
        if (geo = @model.nodes.get 'geoloc')
            @geo = geo.toJSON yes
        #permissions
        affiliation = app.users.current.affiliations.get(@model.nodes.get('posts')?.get 'nodeid') or ""
        @user =
            followingThisChannel: affiliation in ["owner", "publisher", "moderator", "member", "outcast"]
            hasRightToPost: affiliation in ["owner", "publisher", "moderator", "member"]
