{ EventHandler } = require '../../util'


class exports.AuthenticationView extends Backbone.View
    initialize: ->
        super
        @bind 'show', @show
        @bind 'hide', @hide
        @box = $('.centerBox')
        @delegateEvents()
        app.handler.connection.bind 'nobosh', =>
            @error 'nobosh'

    events:
        "click .back.button": "click_back"

    click_back: EventHandler ->
        app.router.navigate "welcome", true

    show: =>
        @box.addClass @cssclass
        @el.find('input').first().focus() # bug on ipad: the focus has to be delayed to happen after the transition (on 3d animation enabled devices the slides flip in 3d)

    hide: =>
        @box.removeClass @cssclass

    go_away: =>
        # nicely animate the login form away
        curr_pos = @box.position()
        @box.css(
            top : "#{curr_pos.top}px"
            left: "#{curr_pos.left}px"
        ).animate({top:"#{curr_pos.top + 50}px"}, 200)
         .animate top:"-800px", ->
            $(this).hide()

    error: (type) =>
        app.handler.connection.reset()
        # wobble animation
        curr_pos = @box.position()
        @box.css(
            top : "#{curr_pos.top}px"
            left: "#{curr_pos.left}px"
        ).animate({left:"#{curr_pos.left + 10}"},50)
         .animate({left:"#{curr_pos.left - 10}"},50)
         .animate({left:"#{curr_pos.left + 10}"},50)
         .animate({left:"#{curr_pos.left - 10}"},50)
        @el.find("form").addClass('hasError')
        par = @el.find("##{type}").show().parent()
        do par.show if par.hasClass('error')

    reset: () =>
        @unbind 'hide', @go_away
        @bind 'hide', @hide
        app.handler.connection.unbind "connected", @reset
        @el.find('.leftBox').removeClass "working"
