# views
{ LoadingChannelView } = require 'views/channel/loading'
{ RegisterView } = require 'views/authentication/register'
{ WelcomeView } = require 'views/welcome/show'
{ LoginView } = require 'views/authentication/login'
{ HomeView } = require 'views/home/show'

class exports.Router extends Backbone.Router
    routes : # eg http://localhost:3000/welcome
        ""           :"index"
        "welcome"    :"index"
        "login"      :"login"
        "register"   :"register"
        "more"       :"overview"
        ":id@:domain":"loadingchannel"

    initialize: ->

        # bootstrapping after login or registration
        app.handler.connection.bind "connected", @on_connected

        Backbone.history.start pushState:on


    setView: (view) ->
        return unless view? # TODO access denied msg
        return if view is @current_view
        @current_view?.trigger 'hide'
        @current_view = view
        @current_view.trigger 'show'

    on_connected: =>
        app.views.index = new HomeView
        app.users.target ?= app.users.current
        jid = app.users.target.get('jid')
        @navigate jid
        # in anonymous direct browsing route, navigate above doesn't
        # trigger an URL change event at all
        @loadingchannel jid

    # routes

    index: ->
        if app.handler.connection.connected
            app.views.index ?= new HomeView
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
        app.users.target = app.users.get jid, create:yes

        if app.handler.connection.connected
            channel = app.channels.get jid, create:yes
            app.views.index.setCurrentChannel channel
            @setView app.views.index
        else
            # connect as anony@mous
            do app.handler.connection.connect unless app.users.current
            # Wait for on_connected...
            app.views.loadingchannel ?= new LoadingChannelView
            @setView app.views.loadingchannel
