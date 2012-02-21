{ BaseView } = require '../base'
notification = require '../../templates/channel/error_notification'
private      = require '../../templates/channel/private'

class exports.ErrorNotificationView extends BaseView

    initialize: ({error}) ->
        err = error.message ? error

        if "#{err}".indexOf('forbidden') is 0 # startswith
            @template = private
        else
            @template = notification

        super
        @ready =>
            @trigger('error', err)

    remove: =>
        @ready =>
            @el.remove()
