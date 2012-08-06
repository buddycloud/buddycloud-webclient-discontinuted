unless process.title is 'browser'
    return module.exports =
        src: "anon.html"
        select: () ->
            @select ".overlay"


{ Template } = require 'dynamictemplate'
design = require '../../_design/authentication/overlay'

errorMessage =
    'nobosh':"BOSH service unavailable!"
    'nochannelserver':"The buddycloud server component is unreachable!"
    'regifail':"Cannot create new account."
    'authfail':"Unable to confirm your username or password."
    'connfail':"Connection to the server closed."
    'disconnected':"Thats weird. You disconnected."
    'noname':"please provide a username"
    'nopasswd':"please enter a password"
    "invalidjid":"Username is invalid"


module.exports = design (view) ->
    return new Template schema:5, ->
        @$div class:'overlay', ->

            errors = {}
            view.on 'reset:errors', ->
                for type, error of errors
                    error?.remove()
                errors = {}
            onError = (type) ->
                view.on "error:#{type}", (msg = "") =>
                    errors[type] ?= @$div class:'error'
                    errors[type].text errorMessage[type]+msg
                view.on "remove:error:#{type}", ->
                    errors[type]?.remove()
                    errors[type] = null

            @$div ->
                @$div class:'close', ->
                    @hide() unless view.isClosable()
                @$div class: 'left', ->
                    @$h2 ->
                        view.on 'switch mode', =>
                            switch view.mode
                                when 'register'
                                    @text "buddycloud sign-up"
                                when 'login'
                                    @text "buddycloud login"
                    @$p ->
                        return @remove() if config.registration is off
                        view.on('disable:form', @hide)
                        view.on( 'enable:form', @show)
                        @$span ->
                            view.on 'switch mode', =>
                                switch view.mode
                                    when 'register'
                                        @text "Already on buddycloud?"
                                    when 'login'
                                        @text "Not yet a member?"
                        @$a ->
                            @attr href: "/register"
                            view.on 'switch mode', =>
                                switch view.mode
                                    when 'register'
                                        @attr href:"/login"
                                        @text "Login"
                                    when 'login'
                                        @attr href:"/register"
                                        @text "Register"
                onError.call this, 'nobosh'
                onError.call this, 'nochannelserver'
                @$form ->
                    @$span -> # errors
                        onError.call this, 'regifail'
                        onError.call this, 'authfail'
                        onError.call this, 'connfail'
                        onError.call this, 'disconnected'
                    @$div -> # name
                        @$input ->
                            if view.store_local or view.values.name?
                                @attr value:view.values.name
                            view.on('fillout', => @attr value:view.values.name)
                            @ready ->
                                # a little bit ugly i guess
                                @_jquery.input(view.on_input.bind(view, this))
                        onError.call this, 'noname'
                        onError.call this, 'invalidjid'
                    @$div -> # password
                        # FIXME TODO toggle clear text
                        @$input ->
                            if view.store_local or view.values.password?
                                @attr value:view.values.password
                            view.on('fillout', => @attr value:view.values.password)
                        onError.call this, 'nopasswd'
                    @$div ->
                        @hide() # we start with login mode
                        @$label for:'auth_email', "In case you forget your password, what's your e-mail?"
                        @$input id:'auth_email', type:'email'
                        view.on 'switch mode', =>
                            switch view.mode
                                when 'register' then @show()
                                when 'login'    then @hide()
                    @$span -> # store_local
                        view.on 'switch mode', =>
                            switch view.mode
                                when 'register' then @hide()
                                when 'login'    then @show()
                        @$input ->
                            @attr checked:'checked' if view.store_local
                        @$label ->
                            @$span -> # warning
                                if view.store_local
                                    setTimeout(@show, 200) # FIXME why?
                                view.on 'toggle warning', =>
                                    if view.store_local
                                        @show()
                                    else
                                        @hide()
                    @$span -> # forgot password
                        view.on 'switch mode', =>
                            switch view.mode
                                when 'register' then @hide()
                                when 'login'    then @show()
                    @$p -> # leftBox
                        @$span -> # spinner
                            view.on 'switch mode', =>
                                switch view.mode
                                    when 'register' then @text "signing you up"
                                    when 'login'    then @text "logging you in"
                            view.on('disable:form', @show)
                            view.on('enable:form',  @hide)
                    @$button ->
                        view.on 'switch mode', =>
                            switch view.mode
                                when 'register' then @text "Join buddycloud"
                                when 'login'    then @text "Login"
                        view.on 'disable:form', =>
                            @ready( => @_jquery.prop('disabled', yes))
                        view.on 'enable:form', =>
                            @ready( => @_jquery.prop('disabled', no))


