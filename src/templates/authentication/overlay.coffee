unless process.title is 'browser'
    return module.exports =
        src: "anon.html"
        select: () ->
            @select ".overlay"


{ Template } = require 'dynamictemplate'
design = require '../../_design/authentication/overlay'
{ getCredentials } = require '../../handlers/creds'

module.exports = design (view) ->
    return new Template schema:5, ->
        @$div class:'overlay', ->
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
                        @$span ->
                            view.on 'switch mode', =>
                                switch view.mode
                                    when 'register'
                                        @text "Already a member?"
                                    when 'login'
                                        @text "Not yet a member?"
                        @$a ->
                            return @remove() if config.registration is off
                            @attr href: "/register"
                            view.on 'switch mode', =>
                                switch view.mode
                                    when 'register'
                                        @attr href:"/login"
                                        @text "Login"
                                    when 'login'
                                        @attr href:"/register"
                                        @text "Register"
                @$form ->
                    @$div -> # name
                        if view.store_local
                            @$input ->
                                @attr value:getCredentials()[0] # name
                    @$div -> # password
                        # FIXME TODO toggle clear text
                        if view.store_local
                            @$input ->
                                @attr value:getCredentials()[1] # password
                    @$div ->
                        @hide() # we start with login mode
                        @$label for:'auth_email', "In case you forget your password, what's your e-mail?"
                        @$input id:'auth_email', type:'text'
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


