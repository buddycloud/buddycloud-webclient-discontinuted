{ Model } = require 'models/base'
{ NodeMetadata } = require 'models/metadata/node'
{ Users } = require 'collections/user'
{ Posts } = require 'collections/post'

class exports.Node extends Model

    initialize: ->
        nodeid = @get 'nodeid'
        @metadata = new NodeMetadata parent:this, id:nodeid
        # Subscribers:
        @subscriptions = new Users parent:this
        @affiliations  = new Users parent:this
        @posts        ?= new Posts parent:this

    toJSON: (full) ->
        result = super
        if full
            result.metadata = @metadata.toJSON()
        result

    # I am very afraid of the dead. They walk.
    # but this will be needed for the geonode
    # (its seperated in subnodes, which are themself represented as node)
    update: -> # api function - every node should be updateable

    push_subscription: (subscription) ->
        switch subscription.subscription
            when 'subscribed'
                @subscriptions.get_or_create id: subscription.jid
            when 'unsubscribed', 'none'
                if (user = @subscriptions.get subscription.jid)
                    @subscriptions.remove user

    push_affiliation: (affiliation) ->
        switch affiliation.affiliation
            when 'outcast', 'none'
                if (user = @affiliations.get subscription.jid)
                    @affiliations.remove user
            else # owner, moderator, publisher, member
                @affiliations.get_or_create id: affiliation.jid

    push_post: (post) ->
        @trigger 'post', post

    push_metadata: (metadata) ->
        @metadata.save metadata

    push_error: (error) ->
        @error =
            condition: error.condition
            text: error.text
        @trigger 'error', error

    push_posts_rsm_last: (rsm_last) ->
        # No RSM support or
        # same <last/> as previous page
        if not rsm_last or
           rsm_last is @get('rsm_last')
            @set history_end_reached: yes
        @save { rsm_last }

    can_load_more: ->
        not @has 'history_end_reached'
