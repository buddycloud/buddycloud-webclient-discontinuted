{ Model } = require '../base'
{ NodeMetadata } = require '../metadata/node'
{ Users } = require '../../collections/user'
{ Posts } = require '../../collections/post'

##
# Attributes:
# * id is only the tail for a channel (eg. posts)
# * nodeid is the full node name (eg. /user/astro@spaceboyz.net/posts)
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

        if app.users.current.channels.get(@get 'nodeid')?
            @metadata_synced = yes
        else
            @metadata_synced = no

    push_error: (error) ->
        @error =
            condition: error.condition
            text: error.text
        @trigger 'error', error

    push_posts_rsm_last: (rsm_last) ->
        # No RSM support or
        # same <last/> as previous page
        @posts_end_reached = not rsm_last or
           rsm_last is @posts_rsm_last
        @posts_rsm_last = rsm_last

    # If we are subscribed, newer/updated posts will come in
    # through notifications. No need to poll again.
    # FIXME: clear on xmpp disconnect
    on_posts_synced: ->
        if app.users.current.channels.get(@get 'nodeid')?
            @posts_synced = yes
        else
            @posts_synced = no

    can_load_more_posts: ->
        not @posts_end_reached

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
