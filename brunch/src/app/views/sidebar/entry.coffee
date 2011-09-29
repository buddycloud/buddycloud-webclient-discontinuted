{ BaseView } = require('views/base')
{ transitionendEvent, getBrowserPrefix } = require 'util'
prefix = getBrowserPrefix()


class exports.ChannelEntry extends BaseView
    template: require 'templates/sidebar/entry'

    initialize: ->
        super
        @model.bind 'change', @render
        @model.bind 'change:node:metadata', @render

    render: =>
        @update_attributes()
        super
        @el.click =>
            @parent.setCurrentEntry @model

    isPersonal : (a, b) =>
        (@channel?.metadata?.owner?.value is app.users.current.get('jid')) and (a ? true) or (b ? false)

    isSelected : (a, b) =>
        (@parent.current?.model.cid is @model.cid) and (a ? true) or (b ? false)

    update_attributes: ->
        @channel = @model.toJSON yes
        if (status = @model.nodes.get 'status')
            @status = status.toJSON yes

    bubble: =>
        return # FIXME turned off because it doesnt work right
        offset = @el.position().top
        # the channel has an offset of 0 - it should stay where it is. so stop
        return off if offset is 0 or @el.hasClass 'bubbleUp'
        channels = $('#channels')
        distance = 20 - offset # TODO add searchbar height
        # enable transitions
        channels.removeClass 'curtainsDown'
        # undock => sets z-index
        @el.addClass 'bubbleUp'
        #  bind the transitionend to the reset function which resets the DOM after the animation
        @el.one transitionendEvent, @reset_bubble
        # enable transitions again and start to move the channels above the moved channel to close the gap
        channels.addClass 'makePlace'
        # animate the channel to bubble up
        @el.css "#{prefix}transform", "translateY(#{distance}px)"


    reset_bubble: (ev) =>
        channels = $('#channels')
        # disable transitions
        channels.addClass 'curtainsDown'
        # extract the bubbling channel from the DOM, remove the classes, reset the transformation and add it at the top
        #@$.detach()
        @el.removeClass 'undock bubbleUp'
        @el.css "#{prefix}transform", ""
        #@$.insertAfter personal_channel
        channels.removeClass 'makePlace'

