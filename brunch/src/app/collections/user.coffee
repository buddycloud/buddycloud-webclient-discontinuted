{ Collection } = require 'collections/base'
{ User } = require 'models/user'

class exports.Users extends Collection
    model: User

    get: (jid, options = {}) ->
        opts = _.clone options
        opts.create = no
        user = super(jid, opts)
        if not user and options.create
            @create app.users.get jid, options


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

    create: (jid, options = {}) ->
        jid = jid?.jid or jid
        options.create = yes
        options.update = yes
        # this is what a empty user looks like
        super {id:jid, jid}, options
