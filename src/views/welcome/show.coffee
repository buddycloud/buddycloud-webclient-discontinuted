{ EventHandler } = require '../../util'


class exports.WelcomeView extends Backbone.View
    template: require '../../templates/welcome/show.eco'

    initialize: ->
        @el = $('.centerBox')
        do @render
        super

    events:
        "click #goLogin"   : 'click_login'
        "click #goRegister": 'click_register'

    render: ->
        @$('#index').html $(@template())
        @delegateEvents()

    click_login: EventHandler ->
        app.router.navigate "login"    , true

    click_register: EventHandler ->
        app.router.navigate "register" , true
