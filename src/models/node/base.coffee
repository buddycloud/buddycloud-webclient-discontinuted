{ Model } = require '../base'
{ NodeMetadata } = require '../metadata/node'
{ Users } = require '../../collections/user'
{ Posts } = require '../../collections/post'
{ Collection } = require '../../collections/base'

##
# Attributes:
# * id is only the tail for a channel (eg. posts)
# * nodeid is the full node name (eg. /user/astro@spaceboyz.net/posts)
class exports.Node extends Model
    defaults:
        nodeid:undefined

    initialize: ->
        nodeid = @get 'nodeid'
        @metadata = new NodeMetadata parent:this, id:nodeid
        @posts   ?= new Posts parent:this
        @posts.bind 'unsync', =>
            @push_error null
        # TODO: comparator by id
        @subscribers = new Collection()
        @affiliations = new Collection()

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
        old_subscription = @subscribers.get(subscription.jid)

        subscription.id ?= subscription.jid
        subscription = @subscribers.get_or_create subscription
        @trigger 'subscriber:update', subscription

        s = subscription.get('subscription')
        os = old_subscription?.get('subscription')
        # Transition from/to subscribed
        if s isnt os and (s is 'subscribed' or os is 'subscribed')
            @trigger 'unsync'

    push_affiliation: (affiliation) ->
        affiliation.id ?= affiliation.jid
        affiliation = @affiliations.get_or_create affiliation

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
        @error = error ?
            condition: error.condition
            text: error.text
        @trigger 'error', error
