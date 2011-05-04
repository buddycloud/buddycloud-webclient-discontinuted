class SettingsController extends Backbone.Controller
  routes :
    "settings" : "index"

  index: ->
    new SettingsView { el : $('#content'), model : app.currentUser }

@SettingsController = SettingsController

new SettingsController
