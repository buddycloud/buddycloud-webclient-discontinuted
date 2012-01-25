{ BaseView } = require '../base'

class exports.ErrorNotificationView extends BaseView
    template: require '../../templates/channel/error_notification'

    initialize: ({error}) ->
        super
        @ready =>
            @trigger('error', error.message ? error)

