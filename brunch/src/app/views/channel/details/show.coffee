{ GeoDetail } = require 'views/channel/details/geo'
{ UserList } = require 'views/channel/details/list'

class exports.ChannelDetails extends Backbone.View
    template: require 'templates/channel/details/show'

    initialize: ({@parent}) ->
        @el = $(@template this).attr id:@cid
        @geo = new GeoDetail model:@model, parent:this

        @list = {}
        @list.moderator = new UserList
            model:@model
            parent:this
            name:'moderators'
            usertypes:['owner', 'moderator']
        @list.followers = new UserList
            model:@model
            parent:this
            name:'followers'
            usertypes:['publisher', 'member']

        @model.bind 'change', @render
        @model.bind 'change:node:metadata', @render
        super

    render: =>
        @update_attributes()
        old = @el; old.replaceWith @el = $(@template this).attr id:@cid
        meta = @el.find('.meta')

        do @geo.render
        meta.append @geo.el

        for own listname, list of @list
            do list.render
            meta.append list.el

        @el.find('.infoToggle').click => @el.toggleClass('hidden')

    update_attributes: ->
        if (channel = @model.nodes.get 'posts')
            @channel = channel.toJSON yes
