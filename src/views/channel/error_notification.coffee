{ BaseView } = require '../base'

class exports.ErrorNotificationView extends BaseView
    template: require '../../templates/channel/error_notification'

    show: (error) =>
        @ready =>
            @trigger 'error', error.message
            @el.addClass 'visible'

    hide: =>
        @el?.removeClass 'visible'

