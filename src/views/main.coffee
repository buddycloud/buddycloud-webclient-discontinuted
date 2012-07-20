{ ChannelView } = require './channel/index'
{ Channels } = require '../collections/channel'
{ Sidebar } = require './sidebar/index'
{ MinimalSidebar } = require './sidebar/minimal'
{ BaseView } = require './base'
{ CreateTopicChannelView } = require './create_topic_channel/index'

class exports.MainView extends BaseView
    template: require '../templates/main'
    adapter: 'jquery'

    events:
        'scroll': 'on_scroll'

    initialize: ({@channels} = {}) ->
        super
        @bind 'show', @show
        @bind 'hide', @hide
        @current = undefined
        # sidebar entries
        @views = {} # this contains the channelnode views
        @timeouts = {} # this contains the channelview remove timeouts
        @channels ?= new Channels
        @channels.comparator = (a, b) =>
            if (filter = @sidebar.search.filter).length
                ai = a.id.indexOf(filter)
                bi = b.id.indexOf(filter)
                return  1 if ai is -1 and bi isnt -1
                return -1 if bi is -1 and ai isnt -1
            if a.unread_count or b.unread_count
                unless a.unread_count is b.unread_count
                    return b.unread_count - a.unread_count
            da = new Date(a.nodes.get('posts')?.posts.first()?.get_last_update() or 0).getTime()
            db = new Date(b.nodes.get('posts')?.posts.first()?.get_last_update() or 0).getTime()
            return db - da


        do @updateSidebar # initialize
        @on('update sidebar', @updateSidebar)

        # special because normaly parents add their children views to the dom
        @render =>
            app.users.current.channels.on('add', @add_channel)
            app.users.current.channels.forEach(  @add_channel)
            @channels.on('remove', @remove_channel_view)
            # FIXME: let the ChannelView be created on-demand, they're
            # rendering much too often during startup. mrflix supposedly says
            #@channels.bind 'add',    @new_channel_view
            # if we already found a view in the cache
            #@current?.el.show()

            @setCurrentChannel(@_first_channel)

    updateSidebar: () ->
        isanon = app.users.isAnonymous(app.users.current)
        return if @_sidebar_isanon_before is isanon
        @_sidebar_isanon_before = isanon
        @sidebar?.destroy(rmel:no)
        @sidebar = if isanon
                new MinimalSidebar
                    model: @channels
                    parent:this
            else
                new Sidebar
                    model: @channels
                    parent:this
        @sidebar.search.on('filter', @sort_channels)
        if @rendered
            @sidebar.once('template:create', @trigger.bind(this, 'sidebar:template'))
            @sidebar.render =>
                @sidebar.moveIn()
        @ready =>
            body = $('body')
            if app.users.isAnonymous(app.users.current)
                body.addClass('anonymous')
            else
                body.removeClass('anonymous')


    render: (callback) ->
        super ->
            body = $('body').removeClass('start')
            body.append(@$el)
            @$el.show()
            @sidebar.once('template:create', @trigger.bind(this, 'sidebar:template'))
            @sidebar.render()
            callback?()

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

        if @current isnt old
            old?.trigger 'hide'
            @sidebar.setCurrentEntry channel
            @current.trigger 'show'

    sort_channels: () =>
        # don't interfere with current event chain
        process.nextTick =>
            @channels.sort()

    add_channel: (channel) =>
        channel = @channels.get_or_create(channel)
        channel.on('update:unread', @sort_channels)
        channel.nodes.get_or_create(id:'posts').on('post:updated', @sort_channels)

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
        @views[channel.cid]?.destroy()
        delete @views[channel.cid]
        delete @timeouts[channel.cid]

    on_create_topic_channel: =>
        @current?.trigger 'hide'
        @current = new CreateTopicChannelView(parent: this)
        @current.once 'template:create', (tpl) =>
            @trigger 'subview:content', tpl
        @current.render()

    on_scroll: =>
        @current?.on_scroll()

    destroy: =>
        return if @destroyed
        @sidebar.destroy()
        @channels.forEach(@remove_channel_view)
        for prop in ['sidebar', 'channels', 'views', 'timeouts', 'current']
            delete this[prop]
        super
