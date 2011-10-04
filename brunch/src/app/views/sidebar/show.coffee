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

        @search = new Searchbar parent:this
        @el.append @search.el

        # sidebar entries
        @current = undefined
        @views = {} # this contains the channel entry views
        @parent.channels.forEach        @new_channel_entry
        @parent.channels.bind 'change', @new_channel_entry
        @parent.channels.bind 'add',    @new_channel_entry
        @parent.channels.bind 'all', =>
            app.debug "sidebar CHEV-ALL", arguments

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

    setCurrentEntry: (channel) =>
        old = @current
        unless (@current = @views[channel.cid])
            @current = @new_channel_entry channel
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
