class CommonConnectingView extends Backbone.View
  initialize: ->
    @el = $("#auth-container")
    @render()
    
  render: =>
    @el.html($templates.commonConnecting())
    @delegateEvents()

@CommonConnectingView = CommonConnectingView

