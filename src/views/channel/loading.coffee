
class exports.LoadingChannelView extends Backbone.View
    template: require '../../templates/channel/loading'

    initialize: ->
        @bind 'hide', @hide
        do @render

    render: =>
        tpl = @template( jid: app.users.target.get('jid') )
        tpl.ready =>
            @el = tpl.jquery
            $('body').removeClass('start').addClass('center').append @el
            $('.centerBox').hide()

    hide: =>
        @el?.remove()
        $('body').removeClass('center')

