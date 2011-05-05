class SettingsController extends Backbone.Controller
  routes :
    "settings" : "index"

  index: ->
    app.focusTab('Settings')
    new SettingsView { el : $('#content'), model : app.currentUser }

@SettingsController = SettingsController

new SettingsController
