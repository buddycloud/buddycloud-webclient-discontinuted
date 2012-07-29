# views
{ Startpage } = require '../views/discover/startpage'
{ LoadingChannelView } = require '../views/channel/loading'
{ DiscoverView } = require '../views/discover/index'
{ OverlayView } = require '../views/authentication/overlay'
{ MainView } = require '../views/main'

class exports.Router extends Backbone.Router
    routes : # eg http://localhost:3000/discover
        ""           :"index"
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
        app.on(   'connected', @on_connected)
        app.on('disconnected', @on_disconnected)
        @connected = no

    navigate: ->
        @last_fragment = Backbone.history.fragment unless @current_view?.overlay
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
        @connected = yes
        if app.users.target?
            jid = app.users.target.get('id')
            if app.views.discover
                app.views.index?.destroy()
                app.views.index = new MainView
            else
                app.views.index?.trigger 'update sidebar'
                app.views.index ?= new MainView
            @navigate jid
            # in anonymous direct browsing route, navigate above doesn't
            # trigger an URL change event at all
            @loadingchannel jid
        else if app.views.discover?
            do @discover
        if app.views.start?
            if app.users.isAnonymous(app.users.current)
                app.views.start.update()
            else
                app.views.start.destroy()
                app.views.start = null

    on_disconnected: =>
        return unless @connected
         # we are still on the welcome site
        return unless app.views.index?.constructor is MainView
        @connected = no
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
                @navigate app.users.current.get 'id', true
            else
                app.views.start ?= new Startpage
                @setView app.views.start
                return
        @setView app.views.index

    login: ->
        app.views.auth ?= new OverlayView
        app.views.auth.setMode 'login'
        @setView app.views.auth

    register: ->
        app.views.auth ?= new OverlayView
        app.views.auth.setMode 'register'
        @setView app.views.auth

    overview: ->
        @setView app.views.overview

    loadingchannel: (id, domain) ->
        jid = if domain then "#{id}@#{domain}" else id
        jid = jid.toLowerCase()
        app.users.target = app.users.get_or_create id: jid

        if app.handler.connection.connected
            app.views.index ?= new MainView
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
        if app.views.discover is 'wait'
            app.views.discover = new DiscoverView(parent:app.views.index)
        else unless app.views.discover?
            app.views.discover = 'wait'
            do @discover if @connected
            return

        if @connected
            app.views.index ?= new MainView
            app.views.discover.update()
            @setView app.views.discover


