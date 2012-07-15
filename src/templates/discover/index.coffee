unless process.title is 'browser'
    return module.exports =
        src: "discover.html"
        select: () ->
            el = @select ".content", ".discoverChannels > *"
            el.prepend('<span class="login button"/>')
            return el


{ Template } = require 'dynamictemplate'
design = require '../../_design/discover/index'

module.exports = design (view) ->
    return new Template schema:5, ->
        @$div class:'content', ->
            login = @$span class:'login button', "Login"
            update_login = =>
                if app.users.isAnonymous(app.users.current)
                    login.show()
                else
                    login.hide()
            app.on(   'connected', update_login)
            app.on('disconnected', update_login)
            do update_login

            @$div class:'discoverChannels', ->
                view.on("subview:group", @add)

        view.on('show', @show)
        view.on('hide', @hide)
