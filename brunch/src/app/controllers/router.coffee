# views
{ DirectChannelView } = require 'views/home/direct'
{ RegisterView } = require 'views/authentication/register'
{ LoginView } = require 'views/authentication/login'
{ IndexView } = require 'views/home/index'
{ HomeView } = require 'views/home/show'

class exports.Router extends Backbone.Router
    routes : # eg http://localhost:8080/index
        ""           :"index"
        "index"     :"index"
        "home"      :"home"
        "login"     :"login"
        "register"  :"register"
        "more"      :"overview"
        ":id@:domain":"directchannel"

    initialize: ->
        # start views
        app.views.index = new IndexView
        app.views.login = new LoginView
        app.views.register = new RegisterView

        # bootstrapping after login or registration
        app.handler.connection.bind "connected", @on_authorize

        Backbone.history.start pushState:on


    setView: (view) ->
        return unless view? # TODO access denied msg
        @current_view?.trigger 'hide'
        @current_view = view
        @current_view.trigger 'show'

    disable_index: =>
        # disable all views available at page load
        delete app.views.index
        delete app.views.login
        delete app.views.register

    on_authorize: =>
        do @disable_index
        app.views.home = new HomeView
        @navigate 'home', true

    build_direct_channel: (jid) =>
        do @disable_index
        # start view
        app.views.direct = new DirectChannelView {jid}

        # connect as anony@mous when no
        do app.handler.connection.connect unless app.users.current

        # bootstrapping after connection process
        app.handler.connection.unbind "connected", @on_authorize
        app.handler.connection.bind   "connected", app.views.direct.build

    # routes

    home:     -> @setView app.views.home
    index:    -> @setView app.views.index
    login:    -> @setView app.views.login
    register: -> @setView app.views.register
    overview: -> @setView app.views.overview

    directchannel: (id, domain) ->
        unless app.views.direct
            @build_direct_channel "#{id}@#{domain}"
        @setView app.views.direct


