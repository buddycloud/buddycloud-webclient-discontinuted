
class exports.AuthenticationView extends Backbone.View

    constructor: ->
        super
        @bind 'show', @show
        @bind 'hide', @hide

    show: =>
        @form?.fadeIn()
        @el.delay(50).fadeIn()

    hide: =>
        @el.fadeOut()

    go_away: =>
        # nicely animate the login form away
        curr_pos = @el.position()
        @el.css(
            top : "#{curr_pos.top}px"
            left: "#{curr_pos.left}px"
        ).animate({top:"#{curr_pos.top + 50}px"}, 200)
         .animate top:"-800px", =>
            @remove()

    error: =>
        # wobble animation
        curr_pos = @el.position()
        @el.css(
            top : "#{curr_pos.top}px"
            left: "#{curr_pos.left}px"
        ).animate({left:"#{curr_pos.left + 10}"},50)
         .animate({left:"#{curr_pos.left - 10}"},50)
         .animate({left:"#{curr_pos.left + 10}"},50)
         .animate {left:"#{curr_pos.left - 10}"},50, ->
            alert "Wrong credentials!" # FIXME more info
