{ GeoDetail } = require 'views/channel/details/geo'
{ UserList } = require 'views/channel/details/list'
{ BaseView } = require('views/base')

class exports.ChannelDetails extends BaseView
    template: require 'templates/channel/details/show'

    initialize: ({@parent}) ->
        super
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

    render: =>
        @update_attributes()
        super
        meta = @el.find('.meta')

        do @geo.render
        meta.append @geo.el

        for own listname, list of @list
            do list.render
            meta.append list.el

        formatdate.hook @el, update: off
        @el.find('.infoToggle').click => @el.toggleClass('hidden')

    update_attributes: ->
        if (posts = @model.nodes.get 'posts')
            @posts = posts.toJSON yes
