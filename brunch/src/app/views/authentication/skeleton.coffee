
class exports.AuthenticationView extends Backbone.View
    initialize: ->
        super
        @bind 'show', @show
        @bind 'hide', @hide
        @box = $('.centerBox')
        @el.find('.back.button').live 'click', =>
            app.router.navigate "/index", true

    show: =>
        @box.addClass @cssclass
        #@el.delay(50).fadeIn()
        #@el.find('.button').fadeIn('slow')

    hide: =>
        #@el.fadeOut()
        #@el.find('.button').fadeOut('slow')

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
