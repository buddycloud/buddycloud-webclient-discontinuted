{ ChannelEntry } = require 'views/sidebar/entry'

# The sidebar shows all channels the user subscribed to
class exports.Sidebar extends Backbone.View
    template: require 'templates/sidebar/show'

    initialize: ->
        # default's not visible due to nice animation
        $('#sidebar').html @template()
        @el = $('#channels')
        @hidden = yes
        # sidebar entries
        @channels = {} # this contains the channel entry views
        new_channel_entry = (channel) =>
            entry = @channels[channel.cid]
            unless entry
                @channels[channel.cid] = entry = new ChannelEntry model:channel
                @el.append entry.el
            entry.render()
        app.users.current.channels.forEach        new_channel_entry
        app.users.current.channels.bind 'change', new_channel_entry
        app.users.current.channels.bind 'add', (channel) =>
            @channels[channel.cid] = entry = new ChannelEntry model:channel
            @el.append entry.el
        app.users.current.channels.bind 'all', =>
            app.debug "sidebar CHEV-ALL", arguments

    # sliding in animation
    moveIn: (t = 200) ->
        @el.animate(left:"0px", t)
        app.views.overview.show(t)
        @hidden = no

    # sliding out animation
    moveOut: (t = 200) ->
        @el.animate(left:"-#{@el.width()}px", t)
        app.views.overview.hide(t)
        @hidden = yes
