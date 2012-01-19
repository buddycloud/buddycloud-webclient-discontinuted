{ BaseView } = require '../base'
{ EventHandler } = require '../../util'


class exports.OverlayLogin extends BaseView
    template: require '../../templates/authentication/overlay'

    initialize: ->
        @render ->
            $('body').prepend @el

    events:
        'click .close': 'hide'

    show: ->
        @ready =>
            @el.fadeIn(300)

    hide: ->
        @ready =>
            @el.fadeOut(100)
