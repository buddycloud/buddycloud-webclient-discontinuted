{ BaseView } = require '../base'
{ EventHandler } = require '../../util'


class exports.CreateTopicChannelView extends BaseView
    template: require '../../templates/create_topic_channel/index'

    events:
        'click #create_button': 'on_click_create'

    on_click_create: EventHandler ->
        metadata =
            title: $('#channel_name').val()
            description: $('#channel_description').val()

        @trigger 'loading:start'
        app.handler.data.create_topic_channel metadata, (err, userid) =>
            if err
                @trigger 'loading:error', err.message
                return

            app.router.navigate "#{userid}", true
