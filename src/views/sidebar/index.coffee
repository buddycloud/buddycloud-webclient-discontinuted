{ ChannelOverView } = require './more'
{ ChannelEntry } = require './entry'
{ Searchbar } = require './search'
{ BaseView } = require '../base'

# The sidebar shows all channels the user is:
# * subscribed to
# * viewed recently
class exports.Sidebar extends BaseView
    template: require '../../templates/sidebar/index'

    events:
        'click #create_topic_channel': 'on_create_topic_channel'
        'click button.discover': 'on_discover'

    initialize: () ->
        super
        @hidden = yes
        @search = new Searchbar
            model:@parent.channels
            parent:this
        @channelsel = null
        @hidden = yes

        # sidebar entries
        @current = undefined
        @views = {} # this contains the channel entry views
        @timeouts = {} # this contains the channelview remove timeouts
#         @model.forEach        @new_channel_entry
        @ready =>
            @model.forEach        @new_channel_entry
            @model.bind 'add',    @new_channel_entry
            @model.bind 'remove', @remove_channel_entry

#         unless app.views.overview?
#             app.views.overview = new ChannelOverView
#         @overview = app.views.overview

    render: (callback) ->
        super ->
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
            @insert_entry(entry)
        @current?.trigger('update:highlight')
        old?.trigger('update:highlight')

        return entry

    remove_channel_entry: (channel, time = 5000) =>
        { el } = @views[channel.cid]
        el.animate {opacity:0}, duration:time
        if @timeouts[channel.cid]?
            clearTimeout @timeouts[channel.cid]
        @timeouts[channel.cid] = setTimeout ( =>
            @views[channel.cid].trigger 'remove'
            delete @timeouts[channel.cid]
            delete @views[channel.cid]
        ), time

    indexOf: (blob) ->
        i = @model.indexOf(blob)
        if @personal?
            # fill the index gap
            i -= 1 if i > @model.indexOf(@personal.model)
        return i

    insert_entry: (entry) ->
        entry.bind 'template:create', (tpl) =>
            tpl.cid = tpl.xml.cid = entry.model.cid # important for the template HACK
            if app.users.isPersonal(entry.model)
                @personal = entry
                @trigger('subview:personalchannel', tpl)
            else
                i = @indexOf(entry.model)
                @trigger('subview:entry', i, tpl)
        entry.render =>
            @$('.tutorial').remove()

    setCurrentEntry: (channel) =>
        old = @current
        unless (@current = @views[channel.cid])
            @current = @new_channel_entry channel
        if @timeouts[@current.model.cid]?
            clearTimeout @timeouts[@current.model.cid]
            @current.$el.clearQueue()
            @current.$el.css opacity:1
            delete @timeouts[@current.model.cid]
        @current?.trigger('update:highlight')
        old?.trigger('update:highlight')


    on_create_topic_channel: =>
        console.log "on_create_topic_channel", arguments...
        old = @current
        @current = null
        old?.trigger('update:highlight')

        app.router.navigate "create-topic-channel", true

    on_discover: =>
        console.log "on_create_topic_channel", arguments...
        old = @current
        @current = null
        old?.trigger('update:highlight')

        app.router.navigate "discover", true


    # sliding in animation
    moveIn: (t = 200) ->
        @$el?.animate(left:"0", t)
#         @overview.show(t)
        @hidden = no

    # sliding out animation
    moveOut: (t = 200) ->
        @$el?.animate(left:"-#{@$el?.width?() ? 0}px", t)
#         @overview.hide(t)
        @hidden = yes
