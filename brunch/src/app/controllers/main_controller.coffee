class exports.MainController extends Backbone.Controller
  routes :
    "home": "home"

  constructor: ->
    super
    app.connection_handler.get_user_subscriptions()

  home: ->
    app.views.home.render()
