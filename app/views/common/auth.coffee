class CommonAuthView extends Backbone.View
  initialize: ->
    @el = $("#auth-container")
    @render()
    
  render: =>
    @el.html($templates.commonAuth { user : app.currentUser } )
    @delegateEvents()

@CommonAuthView = CommonAuthView

