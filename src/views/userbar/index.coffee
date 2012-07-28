{ BaseView } = require '../base'
{ EventHandler } = require '../../util'

class exports.Userbar extends BaseView
    template: require '../../templates/userbar/index'

    events:
        "click .register": "clickRegister"
        "click .login":    "clickLogin"

    clickRegister: EventHandler (ev) ->
        app.router.navigate "register", true

    clickLogin: EventHandler (ev) ->
        app.router.navigate "login", true


