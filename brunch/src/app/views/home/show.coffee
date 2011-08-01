{ ChannelView } = require 'views/channel/show'
{ Sidebar } = require 'views/sidebar/show'

class exports.HomeView extends Backbone.View
    template: require 'templates/home/show'

    initialize: ->
        @sidebar = new Sidebar parent:this
        $('body').removeClass('start').append @el = $(@template())
        $('.centerBox').remove() # FIXME ugly
        @bind 'show', @show
        @bind 'hide', @hide
        @current = undefined
        # sidebar entries
        @channels = {} # this contains the channelnode views
        new_channel_view = (channel) =>
            view = @channels[channel.cid]
            if not view
                view = new ChannelView model:channel, parent:this
                @channels[channel.cid] = view
                @current ?= view

        app.users.current.channels.forEach        new_channel_view
        app.users.current.channels.bind 'change', new_channel_view
        app.users.current.channels.bind 'add', (channel) =>
            view = new ChannelView model:channel, parent:this
            @channels[channel.cid] = view
            unless @current?
                @current = view
                @el.html @current.el
            @render()
        app.users.current.channels.bind 'all', =>
            app.debug "home CHEV-ALL", arguments
        # if we already found a view in the cache
        if @current
            @el.html @current.el
        @el.show()

    setCurrentChannel: (cid) ->
        @current = @channels[cid]
        app.router.navigate "/channel/#{@current.model.get 'jid'}"
        @render()
        @el.html @current?.el

    render: ->
        @sidebar.render()
        @current?.render()

    show: =>
        @render()
        @sidebar.moveIn()
        @current?.trigger 'show'

    hide: =>
        @sidebar.moveOut()
        @current?.trigger 'hide'


