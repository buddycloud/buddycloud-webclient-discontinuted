{ BaseView } = require '../base'
{ transitionendEvent, EventHandler } = require '../../util'


class exports.ChannelEntry extends BaseView
    template: require '../../templates/sidebar/entry'

    initialize: ->
        super
#         @model.bind 'change:node:metadata', @render
        # Update unread counter:
#         @model.bind 'post', @render
        @model.bind 'bubble', @bubble
        bubble = @bubble # FIXME
        @bubble = (args...) =>
            setTimeout ( -> bubble args... ), 200

    events:
        "click": "click_entry"

    render: (callback) =>
        super ->
            @trigger 'update:highlight'
            callback()

    click_entry: EventHandler ->
            app.debug "ChannelEntry.click_entry", @, @model
            @parent.parent.setCurrentChannel @model

    isPersonal : (a, b) =>
        (@model.get('id') is app.users.current.get('id')) and (a ? true) or (b ? false)

    isSelected : (a, b) =>
        (@parent.current?.model.cid is @model.cid) and (a ? true) or (b ? false)


    isFollowed : (a, b) =>
        app.users.current.isFollowing(@model) and (a ? true) or (b ? false)

    bubble: (duration = 500) =>
        return # FIXME totally buggy
        @parent._movingChannels ?= 0

        # relative offset + absolute offset
        offset = @el.position().top + @parent.el.scrollTop()

        # don't bubble if the channel is..
        #  - on top
        #  - bubbling
        return off if offset is 0 or @el.hasClass('bubbleUp')

        # sets z-index so that the element moves on top of all the others
        @el.addClass('bubbleUp')
        # create a gap where the channel starts off
        @el.before $('<div>')
            .height(@el.height())
            .animate {height:0},
                duration: duration
                complete: ->
                    $(this).remove()

        # detach the bubbling channel from the DOM
        # and insert it at the top
        @el.detach().css(top:offset)
        @parent.el.prepend @el

        # wrap a growing holder around it
        @el.wrap $('<div>')
            .css(position:'relative')
            .height(0)
        # bubble the channel
        increase = => @parent._movingChannels += 1
        decrease = => @parent._movingChannels -= 1
        @el.animate({top:0},
            duration: duration
            complete: ->
                decrease()
                $(this)
                    .removeClass('bubbleUp')
                    .css(top:'', 'z-index':'')
                    .unwrap()
        ).css('z-index', increase() + 1)

        # let the holder grow
        @el.parent()
            .animate({height:@el.height()}, duration)
            .css(overflow:'visible')

