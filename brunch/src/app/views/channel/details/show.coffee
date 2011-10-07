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
        @list.following = new UserList
            title:'following'
            model:app.users.get_or_create(id: @model.get 'id').channels
            parent:this
        @list.followers = new UserList
            title:'followers'
            model:@model.nodes.get('posts').users
            parent:this

        @model.nodes.get('posts').metadata.bind 'change', @render

    events:
        "click .infoToggle": "click_toggle"

    click_toggle: EventHandler ->
        @el.toggleClass 'hidden'
        @hidden = @el.hasClass('hidden')

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

    update_attributes: ->
        @metadata = @model.nodes.get('posts').metadata.toJSON()
