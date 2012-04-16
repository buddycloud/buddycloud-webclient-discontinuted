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
            filter: (affiliator) ->
                affiliator.get('affiliation') is 'owner'
        @moderators = new ChannelDetailsList
            title: "moderators"
            model: node.affiliations
            parent: this
            load_more: ->
                # Do nothing as ChannelView already invokes
                # app.handler.data.get_all_node_affiliations()
            filter: (affiliator) ->
                affiliator.get('affiliation') is 'moderator'
        @publishers = new ChannelDetailsList
            title: "followers+post"
            model: node.subscribers
            parent: this
            load_more: @load_more_followers
            filter: (subscriber) =>
                affiliation = node.affiliations.get(subscriber.get 'id')?.get('affiliation')
                subscriber.get('subscription') is 'subscribed' and
                app.users.get_or_create(id: subscriber.get 'id').canPost(@model) and
                    ['owner', 'moderator'].indexOf(affiliation) < 0
        @followers = new ChannelDetailsList
            title: "followers"
            model: node.subscribers
            parent: this
            load_more: @load_more_followers
            filter: (subscriber) =>
                subscriber.get('subscription') is 'subscribed' and
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
            filter: (affiliator) ->
                affiliator.get('affiliation') is 'outcast'

        node.affiliations.bind 'change', (user) =>
            @publishers.trigger 'change:user', user
            @followers.trigger 'change:user', user
        @metadata.bind 'change', =>
            @publishers.trigger 'change:all:users'
            @followers.trigger 'change:all:users'

        app.handler.connector.get_similar_channels @model.get('id'), 16, (err, jids) =>
            unless jids and jids.length > 0
                # Nothing to display
                return
            collection = new Backbone.Collection()
            jids.forEach (jid) ->
                collection.add app.users.get_or_create(id: jid)
            @similar = new ChannelDetailsList
                title: "similar channels"
                model: collection
                parent: this
                load_more: ->
            @ready =>
                @similar.render =>
                    @trigger 'subview:similar', @similar.el


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
            for role in ['owners', 'moderators', 'publishers', 'followers', 'following', 'banned']
                this[role].render()
            callback?.call(this)
