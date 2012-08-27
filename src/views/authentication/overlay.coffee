async = require 'async'
{ BaseView } = require '../base'
{ validateJID:validate } = require '../../controllers/user'
{ getCredentials, setCredentials } = require '../../handlers/creds'
{ EventHandler } = require '../../util'

wobbleAnimation = [
    {m:-10, t: 50}
    {m:+10, t:100}
    {m:-10, t:100}
    {m:+10, t:100}
    {m: +0, t: 50}
]


class exports.OverlayView extends BaseView
    template: require '../../templates/authentication/overlay'
    adapter: 'jquery'
    overlay: yes

    initialize: () ->
        @values = {}
        [@values.name, @values.password] = getCredentials() ? [null, null]
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
        'txtinput #auth_name': 'on_input'
        'click a[href="/register"]': 'onClickRegister'
        'click a[href="/login"]': 'onClickLogin'
        'change #store_local': 'onStoreLocal'
        'submit form': 'onSubmit'

    isClosable: ->
        (app.views.index? or app.views.start?) and app.users.isAnonymous(app.users.current)

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

    check_: (jid) ->
        # append domain if only the name part is provided
        jid += "@#{config.domain}" if jid.indexOf("@") is -1
        jid = jid.toLowerCase()
        if (err = validate(jid))
            s = if err.length > 1 then 's' else ''
            msg =  ". You can't use invalid character#{s}: #{err.join ', '}"
            @error "invalidjid", msg
            return null
        else
            @trigger "remove:error:invalidjid"
            return jid

    on_input: EventHandler (ev) ->
        jid = $(ev.target).val() or ""
        @check_(jid)

    onClickRegister: EventHandler ->
        app.router.navigate "register", true

    onClickLogin: EventHandler ->
        console.debug "onClickLogin clicked."
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
        jid = $('#auth_name').val() ? ""
        password = $('#auth_pwd').val() ? ""
        @submit(jid, password)

    submit: (jid, password) ->
        @trigger 'reset:errors'
        unless jid.length and password.length
            @error "noname" unless jid.length
            @error "nopasswd" unless password.length
            return
        return unless (jid = @check_(jid))
        # disable the form and give feedback
        @trigger 'disable:form'

        switch @mode
            when 'login'
                # the form sumbit will always trigger a new connection
                @start_connection(jid, password)
                # save password. This should be done only if logged in
                # successfully, right?
                setCredentials([jid, password]) if @store_local

            when 'register'
                email = $('#auth_email').val()
                email = undefined unless email.length
                # the form sumbit will always trigger a new connection
                @start_registration(jid, password, email)

    start_connection: (jid, password) ->
        connection = app.relogin jid, password, (err) =>
            console.warn "Error in start_connection", jid, err
            @reset()
            return @error(err.message) if err
            # Navigate to home channel after auth:
            app.users.target ?= connection.user

    start_registration: (jid, password, email) ->
        connection = app.relogin jid
        , { register: yes, password, email }
        , (err) =>
            console.warn "start_registration", jid, err
            @reset()
            return @error(err.message) if err
            # Navigate to home channel after auth:
            app.users.target ?= connection.user
        connection.bind 'registered', =>
            @reset()
            # Navigate to home channel after auth:
            app.users.target ?= connection.user

    reset: () =>
        @trigger 'enable:form'

    fill: (name, password) ->
        @values.password = password
        @values.name = name
        @trigger 'fillout'

    error: (type, message) =>
        @box ?= @$('.modal')
        console.error "'#{type}' during auth (and while waiting for pizzas.)"
        # Tuomas commented this out to make the login form not to disappear
        # when trying to log in with wrong credentials.
        # app.handler.connection.reset()
        # trigger error message
        @$("form").addClass('hasError')
        @trigger "error:#{type}", message
        @trigger "error:all",     message
        # wobble animation
        return if @animating
        curr_pos = @box.position()
        @box.css
            top : "#{curr_pos.top}px"
            left: "#{curr_pos.left}px"
        @animating = yes
        async.mapSeries(
            wobbleAnimation,
            (({m, t}, next) => @box.animate({left:curr_pos.left+m}, t, next)),
            ( => @animating = no))

