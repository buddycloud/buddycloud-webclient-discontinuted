{ BaseView } = require '../base'
{ EventHandler } = require '../../util'


class exports.OverlayLogin extends BaseView
    template: require '../../templates/authentication/overlay'

    initialize: ->
        @render ->
            $('body').prepend(@$el)

    events:
        'click .close': 'hide'
        'click': 'onClick'
        'keydown': 'onKeydown'

    show: ->
        @ready =>
            @$el.fadeIn(300)
            $(document).keydown @onKeydown

    hide: ->
        @ready =>
            @$el.fadeOut(100)
            $(document).unbind 'keydown', @onKeydown

    onClick: (ev) ->
        # Hide when clicking overlay around dialog
        el = ev.target or ev.srcElement
        if el is @$el[0]
            @hide()

    onKeydown: (ev) =>
        if ev.keyCode is 27 or ev.which is 27
            @hide()
