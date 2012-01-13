{ BaseView } = require '../../base'
{ EventHandler } = require '../../../util'

class exports.ChannelDetailsList extends BaseView
    template: require '../../../templates/channel/details/list'

    initialize: ({@title}) ->
        super