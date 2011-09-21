
class exports.IndexView extends Backbone.View
    template: require 'templates/home/index'

    initialize: ->
        @el = $('#index')
        do @render
        @box = $('.centerBox')
        $('#goLogin'   ).live 'click', => app.router.navigate "login"   , true
        $('#goRegister').live 'click', => app.router.navigate "register", true

    render: ->
        @el.html $(@template())

