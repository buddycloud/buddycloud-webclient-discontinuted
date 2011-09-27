{ transitionendEvent } = require 'util'

class exports.ChannelOverView extends Backbone.View

    initialize: ->
        @el = $('#more_channels')
        @el.one 'click', @expand
        @el.hide()

    show: (t = 200) ->
        @el.delay(t * 0.1).fadeIn()

    hide: (t = 200) ->
        @el.delay(t * 0.1).fadeOut()

    expand: =>
        app.router.navigate "more"
        body = $('body')
        body.addClass 'inTransition'
        body.addClass 'channelOverview'
        @el.one('click', @collapse).text "← back"
        @render()

    collapse: =>
        app.router.navigate "home"
        body = $('body')
        body.removeClass 'stateArrived'
        do document.redraw
        body.addClass 'inTransition'
        body.removeClass 'channelOverview'
        @el.one('click', @expand).text "more …"
        @render()

    render: ->
        body = $('body')
        $('#channels').one transitionendEvent, ->
            body.removeClass 'inTransition'
            body.addClass('stateArrived') if body.hasClass 'channelOverview'
