{ BaseView } = require '../../base'
{ EventHandler } = require '../../../util'
{ ChannelDetailsList } = require './list'

class exports.ChannelDetailsView extends BaseView
    template: require '../../../templates/channel/details/index'

    initialize: ->
        super

        node = @model.nodes.get_or_create id: 'posts'
        @metadata = node.metadata

        @moderators = new ChannelDetailsList
            title: "moderators"
            model: node.affiliations
            parent: this
            load_more: ->
                # Do nothing as ChannelView already invokes
                # app.handler.data.get_all_node_affiliations()
            filter: (user) ->
                ['owner', 'moderator'].
                    indexOf(node.affiliations.get(user.get 'id')?.get('affiliation')) >= 0
        @followers = new ChannelDetailsList
            title: "followers"
            model: node.subscribers
            parent: this
            load_more: @load_more_followers
            ignore_users: [@model.get('id')]
        @following = new ChannelDetailsList
            title: "following"
            model: app.users.get_or_create(id: @model.get 'id').channels
            parent: this
            load_more: @load_more_following
            ignore_users: [@model.get('id')]

    load_more_followers: (all) =>
        node = @model.nodes.get_or_create id: 'posts'
        nodeid = node.get 'nodeid'
        app.handler.data.get_all_node_subscriptions nodeid

    load_more_following: (all) =>
        unless app.users.get(@model.get 'id').subscriptions_synced
            app.handler.data.get_all_user_subscriptions @model.get('id')

    events:
        "click .infoToggle": "click_toggle"

    click_toggle: EventHandler ->
        @el.toggleClass 'hidden'

    render: (callback) ->
        super =>
            @moderators.render =>
                @trigger 'subview:moderators', @moderators.el
                @moderators.showAll()
            @followers.render =>
                @trigger 'subview:followers', @followers.el
            @following.render =>
                @trigger 'subview:following', @following.el
            callback?.call(this)
