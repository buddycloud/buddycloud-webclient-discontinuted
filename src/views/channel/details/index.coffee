{ BaseView } = require '../../base'
{ EventHandler } = require '../../../util'
{ ChannelDetailsList } = require './list'

class exports.ChannelDetailsView extends BaseView
    template: require '../../../templates/channel/details/index'

    initialize: ->
        super

        node = @model.nodes.get_or_create id: 'posts'
        @metadata = node.metadata

        @owners = new ChannelDetailsList
            title: "owner"
            model: node.affiliations
            parent: this
            load_more: ->
                # Do nothing as ChannelView already invokes
                # app.handler.data.get_all_node_affiliations()
            filter: (user) ->
                node.affiliations.get(user.get 'id')?.get('affiliation') is 'owner'
        @moderators = new ChannelDetailsList
            title: "moderators"
            model: node.affiliations
            parent: this
            load_more: ->
                # Do nothing as ChannelView already invokes
                # app.handler.data.get_all_node_affiliations()
            filter: (user) ->
                node.affiliations.get(user.get 'id')?.get('affiliation') is 'moderator'
        # TODO: filter affiliations
        @publishers = new ChannelDetailsList
            title: "followers+post"
            model: node.subscribers
            parent: this
            load_more: @load_more_followers
            filter: (subscriber) =>
                app.users.get_or_create(id: subscriber.get 'id').canPost(@model)
        @followers = new ChannelDetailsList
            title: "followers"
            model: node.subscribers
            parent: this
            load_more: @load_more_followers
            filter: (subscriber) =>
                not app.users.get_or_create(id: subscriber.get 'id').canPost(@model)
        @following = new ChannelDetailsList
            title: "following"
            model: app.users.get_or_create(id: @model.get 'id').channels
            parent: this
            load_more: @load_more_following
            filter: (subscription) =>
                subscription.get('id') isnt @model.get('id')
        @banned = new ChannelDetailsList
            title: "banned"
            model: node.affiliations
            parent: this
            load_more: ->
                # Do nothing as ChannelView already invokes
                # app.handler.data.get_all_node_affiliations()
            filter: (user) ->
                node.affiliations.get(user.get 'id')?.get('affiliation') is 'outcast'


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
            @owners.render =>
                @trigger 'subview:owners', @owners.el
                @owners.showAll()
            @moderators.render =>
                @trigger 'subview:moderators', @moderators.el
                @moderators.showAll()
            @publishers.render =>
                @trigger 'subview:publishers', @publishers.el
            @followers.render =>
                @trigger 'subview:followers', @followers.el
            @following.render =>
                @trigger 'subview:following', @following.el
            @banned.render =>
                @trigger 'subview:banned', @banned.el
            callback?.call(this)
