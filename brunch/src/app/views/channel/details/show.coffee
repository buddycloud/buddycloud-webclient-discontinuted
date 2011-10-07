{ GeoDetail } = require 'views/channel/details/geo'
{ UserList } = require 'views/channel/details/list'
{ BaseView } = require 'views/base'
{ EventHandler } = require 'util'

class exports.ChannelDetails extends BaseView
    template: require 'templates/channel/details/show'

    initialize: ({@parent}) ->
        @hidden = yes
        super
        @geo = new GeoDetail model:@model, parent:this

        @list = {}
        @list.followers = new UserList
            title:'followers'
            model:@model.nodes.get('posts').users
            parent:this

        @model.bind 'change', @render
        @model.bind 'change:node:metadata', @render

    events:
        "click .infoToggle": "click_toggle"

    render: =>
        @update_attributes()
        super
        meta = @el.find('.meta')
        @el.toggleClass('hidden', @hidden)

        do @geo.render
        meta.append @geo.el

        for own listname, list of @list
            do list.render
            meta.append list.el

        formatdate.hook @el, update: off

    click_toggle: EventHandler ->
        @el.toggleClass 'hidden'
        @hidden = @el.hasClass('hidden')

    update_attributes: ->
        if (posts = @model.nodes.get 'posts')
            @posts = posts.toJSON yes
