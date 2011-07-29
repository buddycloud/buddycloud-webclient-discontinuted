{ PostsView } = require 'views/channel/posts'

# The channel shows channel content
class exports.ChannelView extends Backbone.View
    template: require 'templates/channel/show'

    initialize: ({@parent}) ->
        @el = $(@template this).attr id:@cid
        @model.bind 'change', @render
        @model.bind 'change:node:metadata', @render
        # create posts node view when it arrives from xmpp or instant when its already cached
        init_posts = =>
            @model.nodes.unbind "add", init_posts
            if postsnode = @model.nodes.get 'channel'
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
        old = @el; old.replaceWith @el = $(@template this).attr id:@cid
        @info = @el.find('.channelDetails')
        if @postsview
            @el.find('.topics').replaceWith @postsview.el
            do @postsview.render
        @el.find('.infoToggle').click => @info.toggleClass('hidden')


    update_attributes: ->
        if (channel = @model.nodes.get 'channel')
            @channel = channel.toJSON yes
        if (mood = @model.nodes.get 'mood')
            @mood = mood.toJSON yes
        if (geo = @model.nodes.get 'geo')
            @geo = geo.toJSON yes
        #permissions
        affiliation = app.users.current.affiliations.get(@model.nodes.get('channel')?.get 'nodeid')
        @user =
            followingThisChannel: affiliation in ["owner", "publisher", "moderator", "member", "outcast"]
            hasRightToPost: affiliation in ["owner", "publisher", "moderator", "member"]
