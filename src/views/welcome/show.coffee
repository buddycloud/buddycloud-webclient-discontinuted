{ View } = require 'backbone'
{ EventHandler } = require '../../util'


class exports.WelcomeView extends View
    template: require '../../templates/welcome/show.html'

    initialize: ->
        @setElement $('.centerBox')

        @on 'show', -> @$el.show()
        @on 'hide', -> @$el.hide()

        do @render

    events:
        "click #goLogin"   : 'click_login'
        "click #goRegister": 'click_register'

    render: ->
        @$('#index').html $(@template())
        $('#goRegister').remove() if config.registration is off
        @delegateEvents()

    click_login: EventHandler ->
        app.router.navigate "login"    , true

    click_register: EventHandler ->
        app.router.navigate "register" , true
