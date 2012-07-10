{ BaseView } = require '../base'
{ getCredentials, setCredentials } = require '../../handlers/creds'
{ EventHandler } = require '../../util'


class exports.OverlayView extends BaseView
    template: require '../../templates/authentication/overlay'
    adapter: 'jquery'
    overlay: yes

    initialize: () ->
        @mode = "login"
        @store_local = getCredentials()? or config.store_credential_default
        @on('show', @show)
        @on('hide', @hide)
        @render ->
            $('body').prepend(@$el)

    events:
        'click .close': 'hide'
        'click': 'onClick'
        'keydown': 'onKeydown'
        'click a[href="/register"]': 'onClickRegister'
        'click a[href="/login"]': 'onClickLogin'
        'change #store_local': 'onStoreLocal'
        'submit form': 'onSubmit'

    isClosable: ->
        app.views.index? and app.users.isAnonymous(app.users.current)

    focus: =>
        # bug on ipad: the focus has to be delayed to happen after the
        # transition (on 3d animation enabled devices the slides flip
        # in 3d)
        @$('input').first().focus()

    setMode: (mode) ->
        @mode = mode
        @ready =>
            @trigger 'switch mode'
            do @focus

    show: =>
        $(document).keydown @onKeydown
        @ready =>
            @$el.fadeIn(300, @focus)

    hide: =>
        $(document).unbind 'keydown', @onKeydown
        @ready =>
            @$el.fadeOut(100)
        @trigger 'close'

    onClickRegister: EventHandler ->
        app.router.navigate "register", true

    onClickLogin: EventHandler ->
        app.router.navigate "login", true

    onClick: (ev) ->
        return unless @isClosable()
        # Hide when clicking overlay around dialog
        el = ev.target or ev.srcElement
        @hide() if el is @$el[0]

    onKeydown: (ev) =>
        return unless @isClosable()
        code = ev.keyCode or ev.which
        @hide() if code is 27 # ESC

    onStoreLocal: (ev) ->
        @store_local = $(ev.target).is(':checked')
        setCredentials() unless @store_local # remove from localStorage
        @trigger 'toggle warning'

    onSubmit: EventHandler (ev) ->
        console.warn "form submit"
        ev.stopPropagation()
        jid = $('#auth_name').val()
        password = $('#auth_pwd').val()
        return if jid.length is 0 or password.length is 0
        # append domain if only the name part is provided
        jid += "@#{config.domain}" if jid.indexOf("@") is -1
        # disable the form and give feedback
        $('#auth_submit').prop "disabled", yes

        switch @mode
            when 'login'
                # Navigate to home channel first
                app.users.target ?= app.users.get_or_create(id: jid)
                # the form sumbit will always trigger a new connection
                @start_connection(jid, password)
                # save password
                setCredentials([jid, password]) if @store_local

            when 'register'
                console.error "rofl"

    start_connection: (jid, password) ->
        app.relogin jid, password, (err) =>
            console.error "RELOGIN", err
#             @reset()
#             if err
#                 @error(err.message)

    start_registration: (name, password, email) ->
        connection = app.relogin name
        , { register: yes, password, email }
        , (err) =>
            console.warn "start_registration", name, err
            @reset()
            # couldnt register? try login …
            if err?.message is "regifail" and app.handler.connection.isRegistered()
                @register_success()
                @login_success()
            else if err
                @error(err.message)
            else
                @login_success()
        connection.bind 'registered', =>
            @register_success()
            # Navigate to home channel after auth:
            app.users.target ?= connection.user

