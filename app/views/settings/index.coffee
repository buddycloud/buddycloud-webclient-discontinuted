class SettingsView extends Backbone.View
  initialize: ->
    @render()
    
  events: {
    'submit form' : 'onSubmit'
  }

  onSubmit: ->
    
  render: ->
    @el.html($templates.settingsIndex { user : @model })

@SettingsView = SettingsView
