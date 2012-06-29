{ BaseView } = require '../base'
{ transitionendEvent, EventHandler } = require '../../util'


class exports.ChannelEntry extends BaseView
    template: require '../../templates/sidebar/entry'

    initialize: ->
        super
        @model.on 'update:unread', =>
            @trigger 'update:unread_counter'

        postsnode = @model.nodes.get_or_create(id: 'posts')
        postsnode.on 'subscriber:update', =>
            @trigger 'update:notification_counter'

        statusnode = @model.nodes.get_or_create(id: 'status')
        statusnode.bind 'post', =>
            @trigger 'update:status', statusnode.posts.at(0)?.get('content')?.value

    events:
        "click": "click_entry"

    render: (callback) ->
        super ->
            @trigger 'update:highlight'
            callback?()

    click_entry: EventHandler ->
            app.debug "ChannelEntry.click_entry", @, @model
            app.router.navigate @model.get('id'), true

    isSelected: =>
        @model.get('id') is @parent.current?.model.get('id')

    bubble: (duration = 500) =>
        return # FIXME
        return if app.users.isPersonal(@model) # dont eva eva bubble the personal channel!1!elf
        @parent._movingChannels ?= 0
        channelsel = @parent.$('#channels > .scrollHolder') # FIXME y ?

        # relative offset + absolute offset
        offset = @$el.position().top + channelsel.scrollTop()

        # don't bubble if the channel is..
        #  - on top
        #  - bubbling
        return off if offset is 0 or @$el.hasClass('bubbleUp')

        # sets z-index so that the element moves on top of all the others
        @$el.addClass('bubbleUp')
        # create a gap where the channel starts off
        @$el.before $('<div>')
            .height(@$el.height())
            .animate {height:0},
                duration: duration
                complete: ->
                    $(this).remove()

        # detach the bubbling channel from the DOM
        # and insert it at the top
        @$el.detach().css(top:offset)
        channelsel.prepend @$el

        # wrap a growing holder around it
        @el.wrap $('<div>')
            .css(position:'relative')
            .height(0)
        # bubble the channel
        increase = => @parent._movingChannels += 1
        decrease = => @parent._movingChannels -= 1
        @$el.animate({top:0},
            duration: duration
            complete: ->
                decrease()
                $(this)
                    .removeClass('bubbleUp')
                    .css(top:'', 'z-index':'')
                    .unwrap()
#                 channelsel.parent().antiscroll()
        ).css('z-index', increase() + 1)

        # let the holder grow
        @$el.parent()
            .animate({height:@$el.height()}, duration)
            .css(overflow:'visible')

