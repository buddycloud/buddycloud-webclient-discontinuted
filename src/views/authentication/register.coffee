{ AuthenticationView } = require './base'
{ EventHandler } = require '../../util'


class exports.RegisterView extends AuthenticationView
    cssclass: 'registerPicked'
    initialize: ->
        @el = $('#register')

        passwd = $('#home_register_new_password')
        confirm = $('#home_register_new_confirm')
        confirm.input ->
            if passwd.val() is confirm.val()
                unless confirm.hasClass 'match'
                    confirm.removeClass 'missmatch'
                    confirm.addClass 'match'
            else
                unless confirm.hasClass 'missmatch'
                    confirm.removeClass 'match'
                    confirm.addClass 'missmatch'


        $('#home_register_new_jid').autoSuggestion
            suffix: (val) ->
                if val is "" or val.indexOf("@") isnt -1
                    ""
                else
                    "@#{config.domain}"

        @el.find('#home_register_account').live 'click', EventHandler (ev) =>
            ev.stopPropagation()
            # the form sumbit will always trigger a new connection
            name = $('#home_register_new_jid').val()
            password = $('#home_register_new_password').val()
            email = $('#home_register_new_email').val()
            email = undefined unless email.length
            if name.length and password.length
                unless confirm.val() is passwd.val()
                    @error "passwdmissmatch"
                    return false
                @start_registration(name, password, email)
                # disable the form
                $('#home_register_submit').prop "disabled", yes
                $('#register_waiting').css "visibility","visible"
                @el.find('.leftBox').addClass "working"
            else
                @error "noname" unless name.length
                @error "nopasswd" unless password.length
        super

    start_registration: (name, password, email) ->
        @unbind 'hide', @hide
        @bind 'hide', @go_away
        connection = app.relogin name
        , { register: yes, password, email }
        , (err) =>
            console.warn "start_registration", name, err
            @reset()
            if err?.message is "regifail" and app.handler.connection.isRegistered()
                    @register_success()
                    @login_success()
                else if err
                    @reset()
                    @error(err.message)
                else
                    @login_success()
        connection.bind 'registered', =>
            @register_success()
            # Navigate to home channel after auth:
            app.users.target ?= connection.user


    register_success: =>
        $('#register_waiting').html $('#login_waiting').html()

    login_success: =>
        $('#home_register_submit').removeAttr "disabled"
        @reset()

    reset: =>
        super
        $('#home_register_submit').prop "disabled", false
        $('#register_waiting').css "visibility","hidden"
