{ Model } = require 'models/base'
{ NodeMetadata } = require 'models/metadata/node'
{ Users } = require('collections/user')
{ Posts } = require('collections/post')

class exports.Node extends Model

    initialize: ->
        nodeid = @get 'nodeid'
        @metadata = new NodeMetadata parent:this, id:nodeid
        # Subscribers:
        @users    = new Users parent:this
        @posts   ?= new Posts parent:this
        @posts.bind 'change:unread', =>
            app.debug "node got unread"
            @trigger 'change:unread'

    toJSON: (full) ->
        result = super
        if full
            result.metadata = @metadata.toJSON()
        result

    # I am very afraid of the dead. They walk.
    update: -> # api function - every node should be updateable

    push_subscription: (subscription) ->
        switch subscription.subscription
            when 'subscribed'
                @users.get_or_create id: subscription.jid
            when 'unsubscribed', 'none'
                if (user = @users.get subscription.jid)
                    @users.remove user

        # TODO: needed by?
        @trigger "subscription:node:#{subscription.node}", subscription

    push_affiliation: (affiliation) ->
        if (user = @users.get affiliation.jid)
            # TODO: how to store affiliations?
            do ->

    push_post: (post) ->
        @trigger 'post', post

    push_metadata: (metadata) ->
        @metadata.save metadata

    push_error: (error) ->
        @error =
            condition: error.condition
            text: error.text
        @trigger 'error', error

    count_unread: ->
        @posts.count_unread()

    mark_read: ->
        @posts.mark_read()
