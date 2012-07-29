{ BaseView } = require '../base'
{ EventHandler } = require '../../util'
{ DiscoverGroupView } = require './group'

class exports.Startpage extends BaseView
    template: require '../../templates/discover/startpage'
    adapter: 'jquery'

    initialize: () ->
        @on('show', @show)
        @on('hide', @hide)
        @render()

    show: ->
        $('body').addClass('startpage')

    hide: ->
        $('body').removeClass('startpage')

    render: (callback) ->
        super ->
            $('body').append(@$el)
            callback?()
