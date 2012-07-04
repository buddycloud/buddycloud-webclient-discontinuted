{ Collection } = require './base'
{ User } = require '../models/user'


class UsersBaseCollection extends Collection
    model: User

    isAnonymous: (user) ->
        user.get('id') is 'anony@mous'

    isPersonal: (user) ->
        user.get('id') is app.users.current.get('id')


class exports.Users extends UsersBaseCollection

    get_or_create: (attrs, options) ->
        super(app.users.get_or_create(attrs, options), options)




# The idea is that only this collection creates models, while the
# other (filtered) collections retrieve the same singleton model
# through the *Store collections.
class exports.UserStore extends UsersBaseCollection
    sync: Backbone.sync

    initialize: ->
        super
        @localStorage = new Store("users")
        console.log "nr of users in cache: #{@localStorage.records.length}"
        @fetch()

