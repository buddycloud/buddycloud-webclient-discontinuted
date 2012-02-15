{ Model } = require '../base'
{ NodeMetadata } = require '../metadata/node'
{ Users } = require '../../collections/user'
{ Posts } = require '../../collections/post'

##
# Attributes:
# * id is only the tail for a channel (eg. posts)
# * nodeid is the full node name (eg. /user/astro@spaceboyz.net/posts)
class exports.Node extends Model
    defaults:
        nodeid:undefined
        subscriptions:{}
        affiliations:{}

    initialize: ->
        nodeid = @get 'nodeid'
        @metadata = new NodeMetadata parent:this, id:nodeid
        @posts   ?= new Posts parent:this

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
        subscriptions = @get 'subscriptions'
        switch subscription.subscription
            when 'subscribed'
                subscriptions[subscription.jid] = subscription.subscription
            when 'unsubscribed', 'none'
                delete subscriptions[subscription.jid]
        @save subscriptions: subscriptions
        @trigger 'subscription:update', subscription

    push_affiliation: (affiliation) ->
        affiliations = @get 'affiliations'
        if affiliation.affiliation is 'none'
            delete affiliations[affiliation.jid]
        else # owner, moderator, publisher, member, outcast
            affiliations[affiliation.jid] = affiliation.affiliation
        @save affiliations: affiliations
        @trigger 'affiliation:update', affiliation

    push_post: (post) ->
        @trigger 'post', post

    push_metadata: (metadata) ->
        @metadata.save metadata

        if app.users.current.channels.get(@get 'nodeid')?
            @metadata_synced = yes
        else
            @metadata_synced = no

    push_error: (error) ->
        @error =
            condition: error.condition
            text: error.text
        @trigger 'error', error

    on_subscribers_synced: ->
        if app.users.current.channels.get(@get 'nodeid')?
            @subscribers_synced = yes
        else
            @subscribers_synced = no

    push_subscribers_rsm_last: (rsm_last) ->
        @subscribers_end_reached = not rsm_last or
            rsm_last is @subscribers_rsm_last
        @subscribers_rsm_last = rsm_last

    can_load_more_subscribers: ->
        not @subscribers_end_reached
