
class exports.IndexView extends Backbone.View
    template: require 'templates/home/index'

    initialize: ->
        @el = $('#index')
        @bind 'show', @show
        @bind 'hide', @hide
        do @render
        @el.hide()
        @box = $('.centerBox')
        $('#goLogin'   ).live 'click', => app.router.navigate "/login"   , true
        $('#goRegister').live 'click', => app.router.navigate "/register", true
        $('.back').live 'click', =>
            @box.removeClass 'loginPicked registerPicked'

    render: ->
        @el.html $(@template())

    show: =>
        @el.delay(50).fadeIn()

    hide: =>
        @el.fadeOut()
