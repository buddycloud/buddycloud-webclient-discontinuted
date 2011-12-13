{ Collection } = require './base'
{ User } = require '../models/user'

class exports.Users extends Collection
    model: User

    get_or_create: (attrs, options) ->
        super(app.users.get_or_create(attrs, options), options)


# The idea is that only this collection creates models, while the
# other (filtered) collections retrieve the same singleton model
# through the *Store collections.
class exports.UserStore extends Collection
    sync: Backbone.sync
    model: User

    initialize: ->
        super
        @localStorage = new Store("users")
        app.debug "nr of users in cache: #{@localStorage.records.length}"
        @fetch()

