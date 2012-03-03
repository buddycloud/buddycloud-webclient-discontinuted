{ BaseView } = require '../base'
{ EventHandler } = require '../../util'


class exports.CreateTopicChannelView extends BaseView
    template: require '../../templates/create_topic_channel/index'

    events:
        'click #create_button': 'on_click_create'
        'change #channel_default_role': 'on_change_role'

    on_click_create: EventHandler ->
        if @$('#channel_public_access').prop('checked')
            access_model = 'open'
        else
            access_model = 'authorize'
        metadata =
            title: @$('#channel_name').val()
            description: @$('#channel_description').val()
            access_model: access_model
            publish_model: 'publishers'
            default_affiliation: @$('#channel_default_role').val()

        @trigger 'loading:start'
        app.handler.data.create_topic_channel metadata, (err, userid) =>
            if err
                @trigger 'loading:error', err.message
                return

            app.router.navigate "#{userid}", true

    on_change_role: =>
        @trigger 'change:role'
