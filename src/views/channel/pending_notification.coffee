{ BaseView } = require '../base'

class exports.PendingNotificationView extends BaseView
    template: require '../../templates/channel/pending_notification'

    initialize: ->
        super

        # Invoke CSS transition
        @ready =>
            setTimeout =>
                @trigger 'visible'
            , 10

    remove: =>
        @trigger 'invisible'
