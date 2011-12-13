{ BaseView } = require '../base'
{ EventHandler } = require '../../util'

class exports.ErrorNotificationView extends BaseView
    template: require '../../templates/channel/error_notification.eco'

    initialize: ({@error}) ->
        super
