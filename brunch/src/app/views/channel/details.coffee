
class exports.ChannelDetails extends Backbone.View
    template: require 'templates/channel/details'

    initialize: ({@parent}) ->
        @el = $(@template this).attr id:@cid
        @model.bind 'change', @render
        @model.bind 'change:node:metadata', @render
        super

    render: =>
        @update_attributes()
        old = @el; old.replaceWith @el = $(@template this).attr id:@cid
        @el.find('.infoToggle').click => @el.toggleClass('hidden')

    update_attributes: ->
        if (channel = @model.nodes.get 'posts')
            @channel = channel.toJSON yes
        if (geo = @model.nodes.get 'geoloc')
            @geo = geo.toJSON yes
