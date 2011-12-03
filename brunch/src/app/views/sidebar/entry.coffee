{ BaseView } = require 'views/base'
{ transitionendEvent, EventHandler } = require 'util'


class exports.ChannelEntry extends BaseView
    template: require 'templates/sidebar/entry'

    initialize: ->
        super
        @model.bind 'change', @render
        @model.bind 'change:node:metadata', @render
        # Update unread counter:
        @model.bind 'post', @render

    events:
        "click": "click_entry"

    render: =>
        @update_attributes()
        super

    click_entry: EventHandler ->
            app.debug "ChannelEntry.click_entry", @, @model
            @parent.parent.setCurrentChannel @model
            @render()

    isPersonal : (a, b) =>
        (@model.get('id') is app.users.current.get('id')) and (a ? true) or (b ? false)

    isSelected : (a, b) =>
        (@parent.current?.model.cid is @model.cid) and (a ? true) or (b ? false)

    isFollowed : (a, b) =>
        app.users.current.isFollowing(oldChannel) and (a ? true) or (b ? false)

    update_attributes: ->
        @channel = @model.toJSON yes
        if (status = @model.nodes.get 'status')
            @status = status.toJSON yes
        @unread_posts_count = @model.count_unread()

    bubble: =>
        return # FIXME turned off because it doesnt work right
        offset = @el.position().top
        # the channel has an offset of 0 - it should stay where it is. so stop
        return off if offset is 0 or @el.hasClass 'bubbleUp'
        channels = $('#channels')
        search = @parent.search.el
        distance = 20 - offset + search.height() + search.position().top
        # enable transitions
        channels.removeClass 'curtainsDown'
        # undock => sets z-index
        @el.addClass 'bubbleUp'
        #  bind the transitionend to the reset function which resets the DOM after the animation
        #@el.one transitionendEvent, @reset_bubble
        # enable transitions again and start to move the channels above the moved channel to close the gap
        channels.addClass 'makePlace'
        # animate the channel to bubble up
        @el.animate
            translateY:"+=#{distance}"
            complete: @reset_bubble


    reset_bubble: (ev) =>
        channels = $('#channels')
        # disable transitions
        channels.addClass 'curtainsDown'
        # extract the bubbling channel from the DOM, remove the classes, reset the transformation and add it at the top
        #@$.detach()
        @el.removeClass 'undock bubbleUp'
        #@el.css "#{prefix}transform", ""
        #@$.insertAfter personal_channel
        channels.removeClass 'makePlace'
        @parent.render()

