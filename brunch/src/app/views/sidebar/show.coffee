{ ChannelOverView } = require 'views/sidebar/more'
{ ChannelEntry } = require 'views/sidebar/entry'
{ Searchbar } = require 'views/sidebar/search'

# The sidebar shows all channels the user subscribed to
class exports.Sidebar extends Backbone.View
    template: require 'templates/sidebar/show'

    initialize: ({@parent}) ->
        # default's not visible due to nice animation
        $('body').append @template()
        @el = $('#channels > .scrollArea')
        @hidden = yes

        @search = new Searchbar parent:this, channels:@parent.channels
        @search.bind 'filter', @render
        @el.append @search.el

        # sidebar entries
        @current = undefined
        @views = {} # this contains the channel entry views
        @timeouts = {} # this contains the channelview remove timeouts
        @parent.channels.forEach        @new_channel_entry
        @parent.channels.bind 'add',    @new_channel_entry
        @parent.channels.bind 'change', @new_channel_entry
        @parent.channels.bind 'remove', @remove_channel_entry

        unless app.views.overview?
            app.views.overview = new ChannelOverView
        @overview = app.views.overview

    new_channel_entry: (channel) =>
        entry = @views[channel.cid]
        unless entry
            entry = new ChannelEntry model:channel, parent:this
            @views[channel.cid] = entry
            @current ?= entry
            @el.append entry.el
        entry.render()
        entry

    remove_channel_entry: (channel) =>
        { el } = @views[channel.cid]
        time = 5000
        el.animate {opacity:0}, duration:time
        if @timeouts[channel.cid]?
            clearTimeout @timeouts[channel.cid]
        @timeouts[channel.cid] = setTimeout ( =>
            @views[channel.cid].el.remove()
            delete @timeouts[channel.cid]
            delete @views[channel.cid]
        ), time

    setCurrentEntry: (channel) =>
        old = @current
        unless (@current = @views[channel.cid])
            @current = @new_channel_entry channel
        if @timeouts[@current.model.cid]?
            clearTimeout @timeouts[@current.model.cid]
            @current.el.clearQueue()
            @current.el.css opacity:1
            delete @timeouts[@current.model.cid]
        @current?.render()
        @current?.bubble()
        old?.render()

    # sliding in animation
    moveIn: (t = 200) ->
        @el.animate(left:"0px", t)
        @overview.show(t)
        @hidden = no

    # sliding out animation
    moveOut: (t = 200) ->
        @el.animate(left:"-#{@el.width()}px", t)
        @overview.hide(t)
        @hidden = yes

    render: =>
        views = {}
        for cid, view of @views
            view.el.detach()
            view.el.css opacity:0.5
            views[cid] = view

        @parent.channels.filter(@search.filter).forEach (channel) =>
            unless (view = @views[channel.cid])
                view = @new_channel_entry channel
            view.el.css opacity:1
            @el.append view.el
            delete views[channel.cid]

        for cid, view of views
            @el.append view.el
