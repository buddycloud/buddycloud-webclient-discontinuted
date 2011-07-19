{ gravatar } = require('helper')

class exports.UserSubscription extends Backbone.Model

  initialize : ->
    @set id:  (@id   = @get('node'))
    @set sink:(@sink = @get('jid')) # nodes subscriber jid
    @set jid: (@jid  = @id.match(/\/user\/(.+@.+)\//)?[1])
    @avatar = gravatar @jid, s:50, d:'retro'

  # fetches and saves the metadata of the subscription
  get_metadata : ->
    app.handlers.data_handler.getMetadata this, (metadata) =>
      @set {metadata}
      @save()
    , ->
      app.debug "metadata_err", arguments
