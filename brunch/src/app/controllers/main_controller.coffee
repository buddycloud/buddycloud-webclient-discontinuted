# needed views
{ Sidebar } = require('views/sidebar/show')
# needed collection
{ UserSubscriptions } = require('collections/user_subscriptions')

class exports.MainController extends Backbone.Controller
  routes :
    "" : "index"
    "/" : "index"
    "/index" : "index"
    "/home": "home"

  constructor: ->
    super
    app.handlers.data_handler.get_user_subscriptions()
    app.collections.user_subscriptions = new UserSubscriptions(app.current_user)
    app.collections.user_subscriptions.fetch()
    new Sidebar().render()

  index : ->
    app.debug "dd"

  home: ->
    app.views.home.render()