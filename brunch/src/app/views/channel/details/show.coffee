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
        postnode = @model.nodes.get('posts')
        @list.following = new UserList
            title:'following'
            model:app.users.get_or_create(id: @model.get 'id').channels
            parent:this
        @list.followers = new UserList
            title:'followers'
            model:postnode.subscriptions
            parent:this

    events:
        "click .infoToggle": "click_toggle"

    click_toggle: EventHandler ->
        @el.toggleClass 'hidden'
        unless @el.hasClass 'hidden'
            @on_show()

    on_show: =>
        console.warn "Channels", @model.get('id'), "on_show"
        node = @model.nodes.get_or_create id: 'posts'
        nodeid = node.get 'nodeid'
        step = (err) =>
            if err
                # Cancel on all errors:
                return
            unless node.subscribers_synced
                app.handler.data.get_node_subscriptions nodeid, step
            else if node.can_load_more_subscribers()
                app.handler.data.get_more_node_subscriptions nodeid, step
        step()
        unless app.users.get(@model.get 'id').subscribers_synced?
            app.handler.data.get_user_subscriptions @model.get('id')
        @render()

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
        @metadata = @model.nodes.get_or_create(id: 'posts').metadata.toJSON()
