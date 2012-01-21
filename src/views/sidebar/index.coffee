{ ChannelOverView } = require './more'
{ ChannelEntry } = require './entry'
{ Searchbar } = require './search'
{ BaseView } = require '../base'

# The sidebar shows all channels the user is:
# * subscribed to
# * viewed recently
class exports.Sidebar extends BaseView
    template: require '../../templates/sidebar/index'

    initialize: () ->
        super
        @hidden = yes
        @search = new Searchbar
            model:@parent.channels
            parent:this
#         @search.bind 'filter', @render

        @channelsel = null
        @hidden = yes

        $(window).resize =>
            @channelsel?.parent().antiscroll()

        # sidebar entries
        @current = undefined
        @views = {} # this contains the channel entry views
        @timeouts = {} # this contains the channelview remove timeouts
#         @model.forEach        @new_channel_entry
        @model.bind 'add',    @new_channel_entry
        @model.bind 'remove', @remove_channel_entry

#         unless app.views.overview?
#             app.views.overview = new ChannelOverView
#         @overview = app.views.overview

    render: (callback) ->
        super ->
            # goes straight to MainView::template
            # add this view to the dom before searchbar is ready rendered
            @parent.trigger "subview:sidebar", @el
            @channelsel = $('#channels > .scrollHolder')
            @search.render(callback)
#         @$('.tutorial').remove()
#         if channels.length < 2
#             @el.append @tutorial()

    new_channel_entry: (channel) =>
        old = @current
        entry = @views[channel?.cid]
        unless entry
            entry = new ChannelEntry
                model:channel
                parent:this
            @views[channel.cid] = entry
            @current ?= entry
            entry?.render =>
                @ready =>
                    if @channelsel?
                        if entry.isPersonal()
                            @trigger('subview:personalchannel', entry.el)
                        else
                            @trigger('subview:entry', entry.el)

                        @channelsel.parent().antiscroll()
                    @$('.tutorial').remove()
        @current?.trigger('update:highlight')
        old?.trigger('update:highlight')

        return entry

    remove_channel_entry: (channel, time = 5000) =>
        { el } = @views[channel.cid]
        el.animate {opacity:0}, duration:time
        if @timeouts[channel.cid]?
            clearTimeout @timeouts[channel.cid]
        @timeouts[channel.cid] = setTimeout ( =>
            @views[channel.cid].el?.remove?()
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
        @current?.trigger('update:highlight')
        old?.trigger('update:highlight')

    getChannelEntry: (userid) =>
        for own cid, view of @views
            if userid is view.model.get('id')
                return view
        return

    # sliding in animation
    moveIn: (t = 200) ->
        @el.animate(left:"0", t)
#         @overview.show(t)
        @hidden = no

    # sliding out animation
    moveOut: (t = 200) ->
        @el.animate(left:"-#{@el.width?()}px", t)
#         @overview.hide(t)
        @hidden = yes
