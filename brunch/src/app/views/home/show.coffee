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
        new_channel_view = (channel) =>
            view = @views[channel.cid]
            if not view
                view = new ChannelView model:channel, parent:this
                @views[channel.cid] = view
                @current ?= view

        app.users.current.channels.bind 'add', (channel) =>
            @channels.add channel
        app.users.current.channels.forEach (channel) =>
            @channels.add channel
            new_channel_view channel

        @channels.bind 'change', new_channel_view
        @channels.bind 'add', (channel) =>
            view = new ChannelView model:channel, parent:this
            @views[channel.cid] = view
            unless @current?
                @current = view
                @el.html @current.el
            @render()
        @channels.bind 'all', =>
            app.debug "home CHEV-ALL", arguments
        # if we already found a view in the cache
        if @current
            @el.html @current.el
        @sidebar = new Sidebar parent:this
        $('body').removeClass('start').append @el
        $('.centerBox').remove() # FIXME ugly
        @el.show()

    setCurrentChannel: (channel) =>
        @current = @views[channel.cid]
        app.router.navigate @current.model.get 'jid'
        @el.html @current?.el
        @sidebar.setCurrentEntry channel

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


