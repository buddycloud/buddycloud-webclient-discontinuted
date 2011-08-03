{ GeoDetail } = require 'views/channel/details/geo'

class exports.ChannelDetails extends Backbone.View
    template: require 'templates/channel/details/show'

    initialize: ({@parent}) ->
        @el = $(@template this).attr id:@cid
        @geo = new GeoDetail model:@model, parent:this

        @model.bind 'change', @render
        @model.bind 'change:node:metadata', @render
        super

    render: =>
        @update_attributes()
        old = @el; old.replaceWith @el = $(@template this).attr id:@cid

        do @geo.render
        @el.find('.meta').append @geo.el

        @el.find('.infoToggle').click => @el.toggleClass('hidden')

    update_attributes: ->
        if (channel = @model.nodes.get 'posts')
            @channel = channel.toJSON yes
