window.app =
    version: '0.0.0-57'
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

require './vendor-bridge'
{ Router } = require './controllers/router'
{ ConnectionHandler } = require './handlers/connection'
{ ChannelStore } = require './collections/channel'
{ UserStore } = require './collections/user'
formatdate = require 'formatdate'
Notificon = require 'notificon'


### could be used to switch console output ###
app.debug_mode = config.debug ? on
app.debug = ->
    console.log "DEBUG:", arguments if app.debug_mode
app.error = ->
    console.error "DEBUG:", arguments if app.debug_mode
Strophe.log = (level, msg) ->
    console.warn "STROPHE:", level, msg if app.debug_mode and level > 0
Strophe.fatal = (msg) ->
    console.error "STROPHE:", msg if app.debug_mode



# show a nice unread counter in the favicon
total_number = 0
app.favicon = (number) ->
    total = total_number + number ? 0
    return if total is total_number or isNaN(total)
    console.warn "notificon", total
    Notificon total or "",
        font:  "9px Helvetica"
        stroke:"#F03D25"
        color: "#ffffff"
    total_number = total



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
    app.handler.connection = new ConnectionHandler

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
    formatdate.hook '[data-date]'

    $(document).ready ->
        # page routing
        app.router = new Router


Modernizr.load
    test:Modernizr.localStorage
    yep:'web/js/store.js'
    complete:app.initialize
