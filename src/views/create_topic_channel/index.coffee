{ BaseView } = require '../base'

JID_INVALID = /[\s\"\&\'\/\:\<\>]/g

class exports.CreateTopicChannelView extends BaseView
    template: require '../../templates/create_topic_channel/index'

    events:
        'input #channel_name': 'on_change_channel_name'
        'keyup #channel_name': 'on_change_channel_name'

    on_change_channel_name: ->
        console.warn "on_change_channel_name", arguments
        input = $('#channel_name')
        text = input.val().
            toLocaleLowerCase().
            replace(JID_INVALID, '')
        if text isnt input.val()
            input.val text
