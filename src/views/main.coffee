{ ChannelView } = require './channel/index'
{ Channels } = require '../collections/channel'
{ Sidebar } = require './sidebar/index'
{ BaseView } = require './base'
{ DiscoverView } = require './discover/index'
{ CreateTopicChannelView } = require './create_topic_channel/index'

class exports.MainView extends BaseView
    template: require '../templates/main'
    adapter: require 'dt-jquery'

    events:
        'scroll': 'on_scroll'

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

        @sidebar = new Sidebar
            parent:this
            model: @channels

        # special because normaly parents add their children views to the dom
        @render =>
            app.users.current.channels.bind 'add', (channel) =>
                @channels.get_or_create channel
            app.users.current.channels.forEach (channel) =>
                @channels.get_or_create channel

            @channels.bind 'remove', @remove_channel_view
            # FIXME: let the ChannelView be created on-demand, they're
            # rendering much too often during startup. mrflix supposedly says
            #@channels.bind 'add',    @new_channel_view
            # if we already found a view in the cache
            #@current?.el.show()

            @setCurrentChannel(@_first_channel)

    render: (callback) ->
        super ->
            body = $('body').removeClass('start')
            body.append(@el)
            @el.show()
            @sidebar.render(callback)

    show: =>
        @sidebar.moveIn()
        @current?.trigger 'show'

    hide: =>
        @sidebar.moveOut()
        @current?.trigger 'hide'

    setCurrentChannel: (channel) =>
        return unless channel?
        return @_first_channel = channel unless @rendered
        old = @current
        # Throw away if current user did not subscribe:
        oldChannel = @current?.model
        if oldChannel and not app.users.current.isFollowing(oldChannel)
            if @timeouts[oldChannel.cid]?
                clearTimeout @timeouts[oldChannel.cid]
            @timeouts[oldChannel.cid] = setTimeout ( =>
                @channels.remove oldChannel
            ), 15*60*1000 # 15 min

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
        old?.trigger 'hide' unless old is @current

    new_channel_view: (channel) =>
        channel = @channels.get_or_create channel, silent:yes
        unless (view = @views[channel.cid])
            view = new ChannelView
                model:channel
                parent:this
            @views[channel.cid] = view
            view.bind 'template:create', (tpl) =>
                @trigger 'subview:content', tpl
            view.render()
        view

    remove_channel_view: (channel) =>
        delete @views[channel.cid]
        delete @timeouts[channel.cid]

    on_create_topic_channel: =>
        @current?.trigger 'hide'
        @current = new CreateTopicChannelView(parent: this)
        @current.once 'template:create', (tpl) =>
            @trigger 'subview:content', tpl
        @current.render()

    on_discover: =>
        @current?.trigger 'hide'
        @current = new DiscoverView(parent: this)
        @current.once 'template:create', (tpl) =>
            @trigger 'subview:content', tpl
        @current.render()

    on_scroll: =>
        @current?.on_scroll()
