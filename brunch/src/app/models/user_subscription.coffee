class exports.UserSubscription extends Backbone.Model

  initialize : ->
    @set id: (@id  = @get('node'))
    @set jid:(@jid = @id.match(/\/user\/(.+@.+)\//)?[1])

  # fetches and saves the metadata of the subscription
  get_metadata : ->
    app.handlers.data_handler.getMetadata this, (metadata) =>
      @set {metadata}
      @save()
    , ->
      app.debug "metadata_err", arguments
