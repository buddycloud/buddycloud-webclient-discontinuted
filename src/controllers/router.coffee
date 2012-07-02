# views
{ LoadingChannelView } = require '../views/channel/loading'
{ RegisterView } = require '../views/authentication/register'
{ LoginView } = require '../views/authentication/login'
{ DiscoverView } = require '../views/discover/index'
{ MainView } = require '../views/main'

class exports.Router extends Backbone.Router
    routes : # eg http://localhost:3000/welcome
        ""           :"index"
        "welcome"    :"index"
        "login"      :"login"
        "register"   :"register"
        "discover"   :"discover"
        "more"       :"overview"
        ":id@:domain":"loadingchannel"
        "create-topic-channel":"createtopicchannel"

    constructor: ->
        @last_fragment = "/"
        delete @routes['register'] if config.registration is off
        super

    initialize: ->
        Backbone.history.start pushState:on

    navigate: ->
        @last_fragment = Backbone.history.fragment
        # Avoid navigating while edit mode is on
        unless app.views?.index?.current?.isEditing?()
            super

    setView: (view) ->
        return unless view? # TODO access denied msg
        return if view is @current_view
        if view.overlay
            @previous_view = @current_view
            view.once 'close', =>
                @current_view = @previous_view
                @navigate @last_fragment
        else
            @current_view?.trigger 'hide'
        @current_view = view
        @current_view.trigger 'show'

    on_connected: =>
        if @previous_connection?
            @previous_connection.unbind 'disconnected', @on_disconnected
        @previous_connection = app.handler.connection
        app.handler.connection.bind 'disconnected', @on_disconnected

        if app.users.target?
            jid = app.users.target.get('id')
            app.views.index ?= new MainView
            @navigate jid
            # in anonymous direct browsing route, navigate above doesn't
            # trigger an URL change event at all
            @loadingchannel jid
        else if app.views.discover?
            do @discover

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
            unless app.users.isAnonymous(app.users.current)
                return @navigate app.users.current.get 'id', true
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

    createtopicchannel: () ->
        if app.views.index?.on_create_topic_channel?
            app.views.index.on_create_topic_channel()
        else
            @navigate "/"

    discover: () ->
        app.views.index ?= new MainView
        if app.views.discover is 'wait'
            app.views.discover = new DiscoverView(parent:app.views.index)
        else unless app.views.discover?
            app.views.discover = 'wait'
            do @discover if app.handler.connection.connected
            return

        if app.handler.connection.connected
            app.views.discover.render =>
                @setView app.views.discover
        else
            # FIXME and now?
            @setView app.views.index


