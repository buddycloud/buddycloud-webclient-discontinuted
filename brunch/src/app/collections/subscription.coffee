{ Collection } = require 'collections/base'

class exports.SubscriptionStore extends Collection
    sync: Backbone.sync

    constructor: () ->
        @localStorage = new Store("#{@user.get 'jid'}-subscriptions")
        app.debug "nr of #{@user.get 'jid'} subscriptions in cache: #{@localStorage.records.length}"
        super()

    get: (id, options = {}) ->
        if options.all
            super id
        else
            super(id)?.get 'value'
