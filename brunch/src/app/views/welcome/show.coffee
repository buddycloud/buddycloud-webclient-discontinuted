{ EventHandler } = require 'util'


class exports.WelcomeView extends Backbone.View
    template: require 'templates/welcome/show'

    initialize: ->
        @el = $('#index')
        do @render
        @box = $('.centerBox')

    events:
        "click #goLogin"   : 'click_login'
        "click #goRegister": 'click_register'

    render: ->
        @el.html $(@template())

    click_login: EventHandler ->
        app.router.navigate "login"   , true

    click_register: EventHandler ->
        app.router.navigate "register" , true
