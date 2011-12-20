{ ChannelView } = require './channel/index'
{ Channels } = require '../collections/channel'
{ Sidebar } = require './sidebar/index'
{ BaseView } = require './base'

class exports.MainView extends BaseView
    template: require '../templates/main'

    initialize: ->
        super
        @bind 'show', @show
        @bind 'hide', @hide
        @current = undefined
        # sidebar entries
        @views = {} # this contains the channelnode views
        @timeouts = {} # this contains the channelview remove timeouts
        @channels = new Channels
        @channels.comparator = (channel) ->
            a = new Date(channel.last_touched)
            b = new Date(channel.nodes.get('posts')?.posts.at(0)?.get_last_update() or 0)
            a.getTime() - b.getTime()

        @sidebar = new Sidebar parent:this

        # special because normaly parents add their children views to the dom
        @render =>
            @channels.bind 'add', @new_channel_view

    render: (callback) ->
        super ->
            body = $('body').removeClass('start')
            for el in @el
                body.append el
            @el.show()
            @sidebar.render(callback)

    show: =>
        @sidebar.moveIn()
        @current?.trigger 'show'

    hide: =>
        @sidebar.moveOut()
        @current?.trigger 'hide'

    setCurrentChannel: (channel) =>
        @current?.trigger 'hide'
        # Throw away if current user did not subscribe:
        oldChannel = @current?.model
        if oldChannel and not app.users.current.isFollowing(oldChannel)
            if @timeouts[oldChannel.cid]?
                clearTimeout @timeouts[oldChannel.cid]
            @timeouts[oldChannel.cid] = setTimeout ( =>
                @channels.remove oldChannel
            ), 15*60*1000 # 15 min

        #@channels.touch channel, silent:true
        #@sidebar.bubble channel

        unless (@current = @views[channel.cid])
            @current = @new_channel_view channel
        if @timeouts[@current.model.cid]?
            clearTimeout @timeouts[@current.model.cid]
            delete @timeouts[@current.model.cid]
        # Indicate url change without routing:
        app.router.navigate @current.model.get('id'), false

        title = @current.model.nodes.get('posts')?.metadata.get('title')?.value
        document.title = title or @current.model.get('id')

        @sidebar.setCurrentEntry channel
        @current.trigger 'show'

    new_channel_view: (channel) =>
        channel = @channels.get_or_create channel, silent:yes
        unless (view = @views[channel.cid])
            view = new ChannelView
                model:channel
                parent:this
            @views[channel.cid] = view
            view.render =>
                @trigger 'subview:content', view.el
        view

    remove_channel_view: (channel) =>
        delete @timeouts[channel.cid]
        delete @views[channel.cid]
