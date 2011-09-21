
class exports.SubscriptionStore extends Backbone.Collection
    constructor: (@user) ->
        @localStorage = new Store("#{@user.get 'jid'}-subscriptions")
        app.debug "nr of #{@user.get 'jid'} subscriptions in cache: #{@localStorage.records.length}"
        super()

    get: (id, everything) ->
        return super(id) if everything
        super(id)?.get('value')

    update: (id, value) ->
        if (subscription = @get(id, yes))
            subscription.set {value}
        else
            @create {id, value}
