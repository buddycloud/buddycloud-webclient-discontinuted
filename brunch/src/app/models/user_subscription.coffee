class exports.UserSubscription extends Backbone.Model
  
  initialize : ->
    @id = @get('node')
    @set('id' : "#{@id}")
    
  # TODO: remove
  test_func : ->
    app.debug "subsc_test"