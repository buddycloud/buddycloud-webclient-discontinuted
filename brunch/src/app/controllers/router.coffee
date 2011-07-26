# views
{ ChannelOverView } = require 'views/sidebar/more'
{ RegisterView } = require 'views/authentication/register'
{ LoginView } = require 'views/authentication/login'
{ IndexView } = require 'views/home/index'
{ HomeView } = require 'views/home/show'

class exports.Router extends Backbone.Router
    routes : # eg http://localhost:8080/#/index
        ""           :"index"
        "/"          :"index"
        "/index"     :"index"
        "/home"      :"home"
        "/login"     :"login"
        "/register"  :"register"
        "/more"      :"overview"

    initialize: ->
        # start views
        app.views.index = new IndexView
        app.views.login = new LoginView
        app.views.register = new RegisterView

        # bootstrapping after login
        app.handler.connection.bind "connected", @authorize

        Backbone.history.start()


    setView: (view) ->
        return unless view? # TODO access denied msg
        @current_view?.trigger 'hide'
        @current_view = view
        @current_view.trigger 'show'


    authorize: =>
        app.views.home     = new HomeView
        app.views.overview = new ChannelOverView
        @navigate '/home', true

    # routes

    home:     -> @setView app.views.home
    index:    -> @setView app.views.index
    login:    -> @setView app.views.login
    register: -> @setView app.views.register
    overview: -> @setView app.views.overview

