{ ChannelView } = require 'views/channel/show'
{ Channels } = require 'collections/channel'
{ Sidebar } = require 'views/sidebar/show'

class exports.HomeView extends Backbone.View
    template: require 'templates/home/show'

    initialize: ->
        @el = $(@template())
        @bind 'show', @show
        @bind 'hide', @hide
        @current = undefined
        # sidebar entries
        @views = {} # this contains the channelnode views
        @channels = new Channels

        app.users.current.channels.bind 'add', (channel) =>
            @channels.create channel, update:yes
        app.users.current.channels.forEach (channel) =>
            @channels.create channel
            @new_channel_view channel
            # Attempt to come up with a default channel:
            if !@current and channel.get('id') is app.users.current.get('id')
                @setCurrentChannel channel

        @channels.bind 'change', @new_channel_view
        @channels.bind 'add',    @new_channel_view
        @channels.bind 'all', =>
            app.debug "home CHEV-ALL", arguments
        # if we already found a view in the cache
        @current?.el.show()

        @sidebar = new Sidebar(parent: this)

        $('body').removeClass('start').append @el
        $('.centerBox').remove() # FIXME ugly

        @render()
        @el.show()

    new_channel_view: (channel) =>
        unless (view = @views[channel.cid])
            view = new ChannelView model:channel, parent:this
            @views[channel.cid] = view
            @el.append view.el
            view.el.hide()
        view

    setCurrentChannel: (channel) =>
        @hideCurrent?()

        if (@current = @views[channel.cid])
            # Present-before view
            @hideCurrent = =>
                @current.el.hide()
        else
            # Temporary view not added by @channels.bind('add')
            @current = @views[channel.cid] = @new_channel_view channel
            @hideCurrent = =>
                @current.el.hide()
                # Dispose when hiding:
                delete @views[channel.cid]
        app.router.navigate @current.model.get('id'), true

        @sidebar.setCurrentEntry channel
        @current.el.show()

    render: ->
        @current?.render()
        @sidebar.render()

    show: =>
        @render()
        @sidebar.moveIn()
        @current?.trigger 'show'

    hide: =>
        @sidebar.moveOut()
        @current?.trigger 'hide'


