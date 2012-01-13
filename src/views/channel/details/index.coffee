{ BaseView } = require '../../base'
{ EventHandler } = require '../../../util'
{ ChannelDetailsList } = require './list'

class exports.ChannelDetailsView extends BaseView
    template: require '../../../templates/channel/details/index'

    initialize: ->
        super

        node = @model.nodes.get_or_create id: 'posts'
        @metadata = node.metadata
        unless node.metadata_synced
            app.handler.data.get_node_metadata node.get('nodeid')

        @followers = new ChannelDetailsList
            title: "followers"
            model: node.subscriptions
            parent: this
            load_more: @load_more_followers
        @following = new ChannelDetailsList
            title: "following"
            model: app.users.get_or_create(id: @model.get 'id').channels
            parent: this
            load_more: @load_more_following

    load_more_followers: =>
        node = @model.nodes.get_or_create id: 'posts'
        nodeid = node.get 'nodeid'
        if node.can_load_more_subscribers()
            app.handler.data.get_more_node_subscriptions nodeid, (err) =>
                unless err
                    @load_more_followers()

    load_more_following: =>
        unless app.users.get(@model.get 'id').subscriptions_synced
            app.handler.data.get_user_subscriptions @model.get('id')

    events:
        "click .infoToggle": "click_toggle"

    click_toggle: EventHandler ->
        @el.toggleClass 'hidden'

    render: (callback) ->
        super =>
            @followers.render =>
                @trigger 'subview:followers', @followers.el
            @following.render =>
                @trigger 'subview:following', @following.el
            callback?.call(this)
