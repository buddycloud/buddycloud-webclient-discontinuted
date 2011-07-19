{ transitionendEvent } = require('helper')

class exports.ChannelOverView extends Backbone.View

  initialize: =>
    @el = $('#more_channels')
    @el.one 'click', @show

  show: =>
    app.router.navigate "/more"
    body = $('body')
    body.addClass 'inTransition'
    body.addClass 'channelOverview'
    @el.one('click', @remove).text "← back"
    @render()

  remove: =>
    app.router.navigate "/home"
    body = $('body')
    body.removeClass 'stateArrived'
    # document.redraw() # FIXME doenst work?
    body.addClass 'inTransition'
    body.removeClass 'channelOverview'
    @el.one('click', @show).text "more …"
    @render()

  render: =>
    app.sidebar.el.one transitionendEvent, ->
      body.removeClass 'inTransition'
      body.addClass('stateArrived') if body.hasClass 'channelOverview'