{ User } = require 'models/user'

class exports.Users extends Backbone.Collection
    sync: -> Backbone.sync.apply(this, arguments) if @localStorage
    model: User

    get: (jid, create) ->
        if (user = super(jid))
            user
        else if create and (user = app.users.create(jid))
            user
        else
            null


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
