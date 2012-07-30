{ BaseView } = require '../base'
{ setCredentials } = require '../../handlers/creds'
{ EventHandler } = require '../../util'

class exports.Userbar extends BaseView
    template: require '../../templates/userbar/index'
    adapter: 'jquery'

    initialize: () ->
        app.on('connected', @update)
        do @update
        do @render

    events:
        "click .register": "clickRegister"
        "click .logout":   "clickLogout"
        "click .login":    "clickLogin"

    clickRegister: EventHandler (ev) ->
        app.router.navigate "register", true

    clickLogin: EventHandler (ev) ->
        app.router.navigate "login", true


    clickLogout: EventHandler (ev) ->
        setCredentials()
        app.relogin()

    update: () =>
        if app.users.isAnonymous(app.users.current)
            $('body').addClass('anonymous')
        else
            $('body').removeClass('anonymous')

    render: (callback) ->
        super ->
            $('body').append(@$el)
            callback?()
