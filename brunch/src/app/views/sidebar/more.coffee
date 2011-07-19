
getBrowserPrefix = () ->
  regex = /^(Moz|Webkit|Khtml|O|ms|Icab)(?=[A-Z])/
  tester = document.getElementsByTagName('script')[0]
  prefix = ""
  for prop in tester.style
    if regex.test prop
        prefix = prop.match(regex)[0]
        break
  prefix = 'Webkit' if 'WebkitOpacity' in tester.style
  prefix ? "-#{prefix.charAt(0).toLowerCase() + prefix.slice(1)}-"

transEndEventNames =
  '-webkit-transition' : 'webkitTransitionEnd'
  '-moz-transition' : 'transitionend'
  '-o-transition' : 'oTransitionEnd'
  'transition' : 'transitionEnd'
transitionendEvent = transEndEventNames[getBrowserPrefix()+'transition']

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