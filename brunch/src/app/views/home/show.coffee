{ ChannelView } = require 'views/channel/show'
{ Sidebar } = require 'views/sidebar/show'

class exports.HomeView extends Backbone.View

    initialize: ->
        @el = $('#content')
        @sidebar = new Sidebar
        @bind 'show', @show
        @bind 'hide', @hide
        @current = undefined
        # sidebar entries
        @channels = {} # this contains the channelnode views
        new_channel_view = (channel) =>
            view = @channels[channel.cid]
            if not view
                @channels[channel.cid] = view = new ChannelView model:channel
                @current ?= view

        app.users.current.channels.forEach        new_channel_view
        app.users.current.channels.bind 'change', new_channel_view
        app.users.current.channels.bind 'add', (channel) =>
            @channels[channel.cid] = view = new ChannelView model:channel
            unless @current?
                @current = view
                @el.html @current.el
            @render()
        app.users.current.channels.bind 'all', =>
            app.debug "home CHEV-ALL", arguments
        # if we already found a view in the cache
        if @current
            @el.html @current.el

    setCurrentChannel: (cid) ->
        @current = @channels[cid]
        @render()
        @el.html @current?.el

    render: ->
        @sidebar.render()
        @current?.render()

    show: ->
        @render()
        @sidebar.moveIn()
        @current?.trigger 'show'

    hide: ->
        @sidebar.moveOut()
        @current?.trigger 'hide'


