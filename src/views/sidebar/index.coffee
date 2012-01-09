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
            channels:@parent.channels
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
        @rendered = no
#         @model.forEach        @new_channel_entry
        @model.bind 'add',    @new_channel_entry
        @model.bind 'remove', @remove_channel_entry

#         unless app.views.overview?
#             app.views.overview = new ChannelOverView
#         @overview = app.views.overview

    render: (callback) ->
        super ->
            return if @rendered
            @rendered = yes
            # goes straight to MainView::template
            # add this view to the dom before searchbar is ready rendered
            @parent.trigger "subview:sidebar", @el
            @channelsel = $('#channels > .scrollHolder')
            @search.render(callback)
            @model.forEach (entry) =>
                @new_channel_entry(entry, force:yes)
#         @$('.tutorial').remove()
#         if channels.length < 2
#             @el.append @tutorial()

    new_channel_entry: (channel, {force} = {}) =>
        render = force ? no
        old = @current
        entry = @views[channel?.cid]
        unless entry
            entry = new ChannelEntry
                model:channel
                parent:this
            @views[channel.cid] = entry
            @current ?= entry
            render = yes
        if @rendered and render
            entry?.render =>
                if @channelsel?
                    if entry.isPersonal()
                        @trigger('subview:personalchannel', entry.el)
#                         entry.el.insertBefore @channelsel
                    else
                        @trigger('subview:entry', entry.el)
#                         @channelsel.append entry.el

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
