{ BaseView } = require('views/base')

class exports.ChannelEntry extends BaseView
    template: require 'templates/sidebar/entry'

    initialize: ->
        super
        @model.bind 'change:node:metadata', @render

    render: =>
        @update_attributes()
        super
        @el.click =>
            @parent.setCurrentEntry @model

    isPersonal : (a, b) =>
        (@channel?.metadata?.owner?.value is app.users.current.get('jid')) and (a ? true) or (b ? false)

    isSelected : (a, b) =>
        (@parent.current?.model.cid is @model.cid) and (a ? true) or (b ? false)

    update_attributes: ->
        if (channel = @model.nodes.get 'channel')
            @channel = channel.toJSON yes
        if (status = @model.nodes.get 'status')
            @status = status.toJSON yes
