# views
{ LoadingChannelView } = require '../views/channel/loading'
{ RegisterView } = require '../views/authentication/register'
{ WelcomeView } = require '../views/welcome/show'
{ LoginView } = require '../views/authentication/login'
{ MainView } = require '../views/main'

class exports.Router extends Backbone.Router
    routes : # eg http://localhost:3000/welcome
        ""           :"index"
        "welcome"    :"index"
        "login"      :"login"
        "register"   :"register"
        "more"       :"overview"
        ":id@:domain":"loadingchannel"

    initialize: ->
        Backbone.history.start pushState:on

    navigate: ->
        # Avoid navigating while edit mode is on
        unless app.views?.index?.current?.isEditing?()
            super

    setView: (view) ->
        return unless view? # TODO access denied msg
        return if view is @current_view
        @current_view?.trigger 'hide'
        @current_view = view
        @current_view.trigger 'show'

    on_connected: =>
        if @previous_connection?
            @previous_connection.unbind 'disconnected', @on_disconnected
        @previous_connection = app.handler.connection
        app.handler.connection.bind 'disconnected', @on_disconnected

        if app.users.target?
            jid = app.users.target.get('jid')
            app.views.index = new MainView
            @navigate jid
            # in anonymous direct browsing route, navigate above doesn't
            # trigger an URL change event at all
            @loadingchannel jid

    on_disconnected: =>
         # we are still on the welcome site
        return unless app.views.index?.constructor is MainView
        $('#sidebar').remove()
        app.views.index.el.remove()
        delete app.views.index

        # Last login succeeded? Reconnect!
        if app.handler.connection.wasConnected()
            setTimeout ( ->
                # Discard all the channel views
                do app.handler.connection.reconnect
            ), 1000
            # Wait for on_connected...
            app.views.loadingchannel ?= new LoadingChannelView
            @setView app.views.loadingchannel

        else @navigate 'login'

    # routes

    index: ->
        if app.handler.connection.connected
            app.views.index ?= new MainView
        else
            app.views.index ?= new WelcomeView
        @setView app.views.index

    login: ->
        app.views.login ?= new LoginView
        @setView app.views.login

    register: ->
        app.views.register ?= new RegisterView
        @setView app.views.register

    overview: ->
        @setView app.views.overview

    loadingchannel: (id, domain) ->
        jid = if domain then "#{id}@#{domain}" else id
        jid = jid.toLowerCase()
        app.users.target = app.users.get_or_create id: jid

        if app.handler.connection.connected
            channel = app.channels.get_or_create id: jid
            app.views.index.setCurrentChannel channel
            @setView app.views.index
        else
            # Wait for on_connected...
            app.views.loadingchannel ?= new LoadingChannelView
            @setView app.views.loadingchannel
