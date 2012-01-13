{ BaseView } = require '../../base'
{ EventHandler } = require '../../../util'

class exports.ChannelDetailsList extends BaseView
    template: require '../../../templates/channel/details/list'

    initialize: ({@title, @load_more}) ->
        super

    events:
        'click .showAll': 'showAll'

    showAll: EventHandler ->
        @trigger 'show:all'
        @load_more()
