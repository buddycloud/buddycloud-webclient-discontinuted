unless process.title is 'browser'
    return module.exports =
        src: "anon.html"
        select: () ->
            @select ".overlay"


{ Template } = require 'dynamictemplate'
design = require '../../_design/authentication/overlay'
{ getCredentials } = require '../../handlers/creds'

errorMessage =
    'nobosh':"BOSH Service unavailable!"
    'nochannelserver':"Channel Server unreachable!"
    'regifail':"Cannot create new Account."
    'authfail':"Unable to confirm your username or password."
    'connfail':"Connection to the server closed."
    'disconnected':"Thats weird. You disconnected."
    'noname':"please provide a username"
    'nopasswd':"please enter a password"


module.exports = design (view) ->
    return new Template schema:5, ->
        @$div class:'overlay', ->

            errors = {}
            view.on 'reset:errors', ->
                for type, error of errors
                    error.remove()
                errors = {}
            onError = (type) ->
                view.on "error:#{type}", (t) =>
                    console.error "ERR", type, t, errors[t]
                    errors[t] ?= @$div({class:'error'}, errorMessage[t])

            @$div ->
                @$div class:'close', ->
                    @hide() unless view.isClosable()
                @$div class: 'left', ->
                    @$h2 ->
                        view.on 'switch mode', =>
                            switch view.mode
                                when 'register'
                                    @text "buddycloud registration"
                                when 'login'
                                    @text "buddycloud login"
                    @$p ->
                        return @remove() if config.registration is off
                        @$span ->
                            view.on 'switch mode', =>
                                switch view.mode
                                    when 'register'
                                        @text "Already a member?"
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
                        if view.store_local
                            @$input ->
                                @attr value:getCredentials()?[0] # name
                        onError.call this, 'noname'
                    @$div -> # password
                        # FIXME TODO toggle clear text
                        if view.store_local
                            @$input ->
                                @attr value:getCredentials()?[1] # password
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
                    @$p ->
                        @$a ->
                        view.on 'switch mode', =>
                            switch view.mode
                                when 'register' then @hide()
                                when 'login'    then @show()
                    @$button ->
                        view.on 'switch mode', =>
                            switch view.mode
                                when 'register' then @text "Join buddycloud"
                                when 'login'    then @text "Login"


