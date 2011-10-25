{ BaseView } = require 'views/base'
{ EventHandler } = require 'util'

class exports.ErrorNotificationView extends BaseView
    template: require 'templates/channel/error_notification'

    initialize: ({@error}) ->
        super
