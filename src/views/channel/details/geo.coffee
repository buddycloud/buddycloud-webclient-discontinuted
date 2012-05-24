{ BaseView } = require '../../base'

# this is the specific view for the geo node

class exports.GeoDetail extends BaseView
    template: require '../../../templates/channel/details/geo.eco'

    initialize: ->
        super
#         @model.bind 'change', @render
#         @model.bind 'change:node:metadata', @render

    render: =>
        @update_attributes()
        super

    update_attributes: ->
        if (posts = @model.nodes.get 'posts')
            @posts = posts.toJSON yes
        if (geo = @model.nodes.get 'geo')
            @geo = geo.toJSON yes
