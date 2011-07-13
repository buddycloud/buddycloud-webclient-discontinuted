{ UserSubscription } = require('models/user_subscription')

class exports.UserSubscriptions extends Backbone.Collection
  model : UserSubscription
  initialize : (user) ->

    # initialize the store
    # TODO: add username to the name of the store
    @localStorage = new Store("#{user.get('jid')}-subscriptions")
    app.debug "nr of subscriptions in cache: #{@localStorage.records.length}"

    # register for user_subscription event
    app.handlers.data_handler.bind "on_user_subscriptions_sync", @on_user_subscriptions_sync

  on_user_subscriptions_sync : (subscriptions) =>
    for sub in subscriptions
      existing = @get(sub.node)
      unless existing
        @create(new UserSubscription(sub))
      else
        existing.save(sub)

  destroyAll : =>
    # IMPORTANT: clone the models, because the @models array shrinks when models are removed from the collection
    for model in _.clone @models
      try
        model.destroy()
      catch e
        app.debug "could not delete", e.toString()
