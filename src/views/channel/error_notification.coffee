{ BaseView } = require '../base'
Notification = require '../../templates/channel/error_notification'
Private      = require '../../templates/channel/private'

class exports.ErrorNotificationView extends BaseView

    initialize: ({error}) ->
        err = error.message ? error

        if "#{err}".indexOf('forbidden') is 0 # startswith
            @template = Private
        else
            @template = Notification

        super
        @ready =>
            @trigger('error', err)

    remove: =>
        @ready =>
            @el.remove()
