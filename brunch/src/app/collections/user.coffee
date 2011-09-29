{ User } = require 'models/user'

class exports.Users extends Backbone.Collection
    sync: -> Backbone.sync.apply(this, arguments) if @localStorage
    model: User

    constructor: ->
        for affiliation in app.affiliations
            do (affiliation) =>
                this["filter_by_#{affiliation}"] = (nodeid) ->
                    @filter_by affiliation, nodeid
        super

    get: (jid, create) ->
        if (user = super(jid))
            user
        else if create and (user = app.users.create(jid))
            user
        else
            null

    filter_by: (affiliation, nodeid) ->
        @filter (user) ->
            user.affiliations.get(nodeid) is affiliation

    filter_by_node: (nodeid) ->
        @filter (user) ->
            user.affiliations.get(nodeid)? isnt undefined

    # filter_by_owner
    # filter_by_moderator
    # filter_by_publisher
    # filter_by_member
    # filter_by_none
    # filter_by_outcast
    # ...


# The idea is that only this collection creates models, while the
# other (filtered) collections retrieve the same singleton model
# through the *Store collections.
class exports.UserStore extends exports.Users
    initialize: ->
        super
        @localStorage = new Store("users")
        app.debug "nr of users in cache: #{@localStorage.records.length}"
        @fetch()

    create: (jid) ->
        if (user = @get(jid))
            user
        else
            @add({ jid })
            @get jid
