{ BaseView } = require '../../base'
{ EventHandler } = require '../../../util'
{ ChannelDetailsList } = require './list'

class exports.ChannelDetailsView extends BaseView
    template: require '../../../templates/channel/details/index'

    initialize: ->
        super

        node = @model.nodes.get_or_create id: 'posts'
        @metadata = node.metadata

        @followers = new ChannelDetailsList title: "followers"
        @following = new ChannelDetailsList title: "following"

    events:
        "click .infoToggle": "click_toggle"

    click_toggle: EventHandler ->
        @el.toggleClass 'hidden'
        unless @el.hasClass 'hidden'
            @on_show()

    on_show: =>
        node = @model.nodes.get_or_create id: 'posts'
        nodeid = node.get 'nodeid'

        # Fill @list.followers model
        step = (err) =>
            if err
                # Cancel on all errors:
                # TODO show them
                return
            unless node.subscribers_synced
                app.handler.data.get_node_subscriptions nodeid, step
            else if node.can_load_more_subscribers()
                app.handler.data.get_more_node_subscriptions nodeid, step
        step()

        # Fill @list.following model
        unless app.users.get(@model.get 'id').subscriptions_synced
            app.handler.data.get_user_subscriptions @model.get('id')

    render: (callback) ->
        super =>
            @followers.render =>
                @trigger 'subview:followers', @followers.el
            @following.render =>
                @trigger 'subview:following', @following.el
            callback?.call(this)

    _render: ->
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

    _update_attributes: ->
        @metadata = @model.nodes.get_or_create(id: 'posts').metadata.toJSON()
