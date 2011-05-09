class SettingsView extends Backbone.View
  initialize: ->
    @render()
    
  events: {
    'submit form' : 'onSubmit'
  }

  onSubmit: (e) ->
    
    e.preventDefault()
    
  render: ->
    @el.html($templates.settingsIndex { user : @model })

@SettingsView = SettingsView
