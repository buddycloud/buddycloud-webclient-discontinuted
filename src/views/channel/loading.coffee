{ BaseView } = require '../base'


class exports.LoadingChannelView extends BaseView
    template: require '../../templates/channel/loading'
    adapter: 'jquery'

    initialize: ->
        @bind 'hide', @hide
        do @render

    render: (callback) ->
        @setElement @template(jid: app.users.target.get('jid')), null, ->
            $('body').removeClass('start').addClass('center').append(@$el)
            $('.centerBox').hide()
            callback?.apply?(this, arguments)

    hide: =>
        @el?.remove()
        $('body').removeClass('center')

