{ BaseView } = require '../base'
{ EventHandler } = require '../../util'

MIN_MESSAGE_TIME = 5000

class exports.FollowNotificationView extends BaseView
    template: require '../../templates/channel/follow_notification'

    initialize: ->
        super

        # Invoke CSS transition
        @ready =>
            setTimeout =>
                @trigger 'visible'
            , 10

    events:
        'click .positive': 'on_click_grant'
        'click .negative': 'on_click_deny'

    on_click_grant: EventHandler ->
        @trigger 'loading'
        app.handler.data.grant_subscription @model, =>
            @trigger 'granted'
            @message_shown = new Date().getTime()

    on_click_deny: EventHandler ->
        @trigger 'loading'
        app.handler.data.deny_subscription @model, =>
            @trigger 'denied'
            @message_shown = new Date().getTime()

    remove: =>
        now = new Date().getTime()
        if @message_shown? and
           @message_shown + MIN_MESSAGE_TIME > now
            # Not shown long enough, procrastinate till later
            setTimeout @remove, @message_shown + MIN_MESSAGE_TIME - now
            return

        @trigger 'invisible'
