{ BaseView } = require '../base'
{ setCredentials } = require '../../handlers/creds'
{ EventHandler } = require '../../util'

class exports.Userbar extends BaseView
    template: require '../../templates/userbar/index'

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

