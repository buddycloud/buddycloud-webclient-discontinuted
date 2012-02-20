{ BaseView } = require '../base'

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

    on_click_grant: =>
        app.handler.data.grant_subscription @model, =>
            @trigger 'granted'

    on_click_deny: =>
        app.handler.data.deny_subscription @model, =>
            @trigger 'denied'

    remove: =>
        @trigger 'invisible'
