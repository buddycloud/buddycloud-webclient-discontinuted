{ GeoDetail } = require 'views/channel/details/geo'
{ UserList } = require 'views/channel/details/list'
{ BaseView } = require 'views/base'
{ EventHandler } = require 'util'

class exports.ChannelDetails extends BaseView
    template: require 'templates/channel/details/show'

    initialize: ({@parent}) ->
        super
        #@geo = new GeoDetail model:@model, parent:this

        @list = {}
        @list.following = new UserList
            title:'following'
            model:app.users.get_or_create(id: @model.get 'id').channels
            parent:this
        @list.followers = new UserList
            title:'followers'
            model:@model.nodes.get('posts').users
            parent:this

        @model.nodes.get('posts').metadata.bind 'change', =>
            if @el.hasClass 'hidden'
                # Show on metadata update:
                @el.removeClass 'hidden'
            @render()

    events:
        "click .infoToggle": "click_toggle"

    click_toggle: EventHandler ->
        @el.toggleClass 'hidden'

    render: =>
        hidden = @el.hasClass 'hidden'
        @update_attributes()
        super
        unless hidden
            @el.removeClass 'hidden'
        meta = @el.find('.meta')

        #do @geo.render
        #meta.append @geo.el

        for own listname, list of @list
            do list.render
            meta.append list.el

        formatdate.hook @el, update: off

    update_attributes: ->
        @metadata = @model.nodes.get('posts').metadata.toJSON()
