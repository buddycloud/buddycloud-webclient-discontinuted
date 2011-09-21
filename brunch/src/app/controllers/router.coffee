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
        @navigate app.users.current.get('jid'), true

    build_direct_channel: (jid) =>
        do @disable_index
        # start view
        app.views.direct = new DirectChannelView {jid}

        # connect as anony@mous when no
        do app.handler.connection.connect unless app.users.current

        # bootstrapping after connection process
        app.handler.connection.unbind "connected", @on_authorize
        app.handler.connection.bind   "connected", app.views.direct.build

    setCurrentChannel: (jid) =>
        nodeid = "/user/#{jid}/posts"
        channel = app.channels.get nodeid

        user = app.users.get jid
        node = channel.nodes.create nodeid
        channel = user.channels.update channel

        # sideeffect: update sidebar by updating current user channels
        node.fetch()
        node.metadata.query()
        app.handler.connection.connector.get_node_posts nodeid

        unless app.views.home
            app.users.current.channels.update channel
            app.views.home ?= new HomeView
        else
            app.views.home.channels.update channel
            app.views.home.setCurrentChannel channel

    # routes

    index:    -> @setView app.views.index
    login:    -> @setView app.views.login
    register: -> @setView app.views.register
    overview: -> @setView app.views.overview

    directchannel: (id, domain) ->
        jid = "#{id}@#{domain}"
        unless app.views.direct
            @build_direct_channel jid
        else if app.views.direct.jid isnt "#{id}@#{domain}"
            app.views.direct = new DirectChannelView {jid}
            app.views.direct.build()
        @setView app.views.direct


