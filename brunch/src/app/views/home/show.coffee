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
                @el.append view.el
                unless @current?
                    @current = view
                else
                    view.el.hide()

        app.users.current.channels.bind 'add', (channel) =>
            @channels.add channel
        app.users.current.channels.forEach (channel) =>
            @channels.add channel
            new_channel_view channel

        @channels.bind 'change', new_channel_view
        @channels.bind 'add', (channel) =>
            view = new ChannelView model:channel, parent:this
            @views[channel.cid] = view
            @el.append view.el
            view.el.hide()
            @current ?= view
            do view.render
        @channels.bind 'all', =>
            app.debug "home CHEV-ALL", arguments
        # if we already found a view in the cache
        @current?.el.show()

        @sidebar = new Sidebar parent:this

        $('body').removeClass('start').append @el
        $('.centerBox').remove() # FIXME ugly

        @render()
        @el.show()

    setCurrentChannel: (channel) =>
        @current?.el.hide()
        @current = @views[channel.cid]
        app.router.navigate @current.model.get 'jid' if @current?

        @sidebar.setCurrentEntry channel
        @current?.el.show()

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


