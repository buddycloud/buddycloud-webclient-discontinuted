class exports.UserSubscription extends Backbone.Model
  
  initialize : ->
    @id = @get('node')
    @set('id' : "#{@id}")
    
  # fetches and saves the metadata of the subscription
  get_metadata : ->
    app.handlers.data_handler.get_metadata @, (metadata) =>
      @set "metadata" : metadata
      @save()
    , ->
      app.debug "metadata_err", arguments
    
  # TODO: remove
  test_func : ->
    app.debug "subsc_test"