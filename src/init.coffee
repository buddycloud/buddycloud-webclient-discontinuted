{ EventEmitter } = require 'events'

window.app = new EventEmitter
app.setMaxListeners(0) # unlimited
app[k] = v for k,v of {
    process
    version: '0.0.2'
    localStorageVersion:'9e5dcf0'
    handler: {}
    views: {}
    affiliations: [ # all possible pubsub affiliations
        "outcast"
        "none"
        "member"
        "publisher"
        "moderator"
        "owner"]
}

require './vendor-bridge'
{ Order } = require 'order'
Notificon = require 'notificon'
formatdate = require 'formatdate'
{ EventEmitter:DomEventEmitter } = require 'domevents'
{ Router } = require './controllers/router'
{ ConnectionHandler } = require './handlers/connection'
{ ChannelStore } = require './collections/channel'
{ UserStore } = require './collections/user'
{ DataHandler } = require './handlers/data'
{ getCredentials } = require './handlers/creds'
{ throttle_callback } = require './util'

# plugin api
require 'dt-selector' # required in plugins
plugin_queue = []
app.use = (plugin) ->
    if plugin_queue?
        # app isn't ready yet
        plugin_queue.push(plugin)
    else
        plugin?.call(this, this, require)

### could be used to switch console output ###
app.debug_mode = config.debug ? on
Strophe.log = (level, msg) ->
    console.warn "STROPHE:", level, msg if app.debug_mode and level > 0
Strophe.fatal = (msg) ->
    console.error "STROPHE:", msg if app.debug_mode



# show a nice unread counter in the favicon
total_number = 0
throttled_Notificon = throttle_callback 20, () ->
    Notificon total_number or "",
        font:  "9px Helvetica"
        stroke:"#F03D25"
        color: "#ffffff"
app.favicon = (number) ->
    total = total_number + number ? 0
    return if total is total_number or isNaN(total)
    throttled_Notificon()
    total_number = total


# provide event listeners for document and window for the whole app
app.document = new DomEventEmitter document
app.window   = new DomEventEmitter window

# trace the tab focus
app.focused = no

onfocus = ->
    app.focused = yes
    app.emit 'focus'
#     document.title = "focus"

onblur = ->
    app.focused = no
    app.emit 'unfocus'
#     document.title = "blur"

app.window.on('focus', onfocus)
app.window.on('blur',  onblur)
# ie
app.document.on('focusin', onfocus)
app.document.on('focusout', onblur)


# app bootstrapping on document ready
app.initialize = ->

    # when domain used an older webclient version before, we clear localStorage
    version = localStorage.getItem('__version__')
    unless app.localStorageVersion is version
        localStorage.clear()
        localStorage.setItem('__version__', app.localStorageVersion)


    # show error message when config isnt loaded
    if typeof config is 'undefined'
        $('#index')
            .addClass('broken')
            .html(do require './templates/welcome/configerror.html')
        return


    # caches
    app.channels = new ChannelStore
    app.users = new UserStore # userstore depends on channelstore

    # strophe handler
    app.handler.data = new DataHandler()
    creds = getCredentials() ? []
    app.setConnection app.relogin(creds...)

    ### the password hack ###
    ### FIXME
    Normally a webserver would return user information for a current session. But there is no such thing in buddycloud.
    To achieve an auto-login we do a little trick here. Once a user has signed in, his browser asks him to store
    the password for him. If the user accepts that, the login form will get filled automatically the next time he signs in.
    So when something is typed into the form on document ready we know that it must be the stored password and can just submit the form.
    ###
    #el = $('#home_login_pwd')
    #pw = el.val()
    #unless pw.length > 0
    #  # the home view sould display some additional info in the future
    #  #app.views.home = new HomeView()
    #else
    #  # prefilled password detected, sign in the user automatically
    #  $('#login_form').trigger "submit"
    formatdate.options.max.unit = 9 # century
    formatdate.options.max.amount = 20 # 2000 years
    formatdate.options.min.string = "a moment ago"
    formatdate.options.hook.update = formatdate.hook.update.dynamictemplate
    # overload formatdate a little bit:
    # track all the time related elements inside of a dt-list ,
    #  so their are nicely handled when they get removed for example.
    formatdate.hookList = new Order ({i}) ->
        idx = @keys[i] # get index tracker
        this[i]?.on 'remove', (el, opts = {}) =>
            # only remove when removed completely
            return if opts.soft
            @remove(idx.i)
    formatdate.hook(formatdate.hookList)
    # TODO is this ugly?
    formatdate.update = (time_element) ->
        return if not time_element
        formatdate.hookList.push (done) ->
            done() # use it in a sync way
            return time_element

    $(document).ready ->
        # page routing
        app.router = new Router
        # initialize plugins
        for plugin in plugin_queue
            plugin?.call(app, app, require)
        plugin_queue = null

app.setConnection = (connection) ->
    # Avoid DataHandler double-binding
    if app.handler.connection isnt connection
        app.handler.connection = connection
        app.handler.connector = connection.connector
        app.users.current = connection.user
        app.handler.data.setConnector connection.connector

app.relogin = (user, password, callback) ->
    console.warn "relogin", user
    if typeof password is 'object'
        { password, register, email } = password
    connection = new ConnectionHandler()

    on_connected = ->
        console.warn "connected", connection

        if app.handler.connection?.connection? and
           app.handler.connection isnt connection
            console.warn "Disconnect", app.handler.connection, connection
            app.handler.connection.connection.disconnect()

        app.setConnection connection
        app.router.on_connected()
        console.warn "app.relogin success callback"
        callback?()
    connection.bind 'connected', on_connected
    ["authfail", "regifail", "authfail", "sbmtfail", "connfail", "disconnected"].forEach (type) ->
        connection.bind type, ->
            callback? new Error(type)

    if register
        connection.register user, password, email
    else
        connection.connect user, password
    connection



Modernizr.load
    test:Modernizr.localStorage
    yep:'web/js/store.js'
    complete:app.initialize
