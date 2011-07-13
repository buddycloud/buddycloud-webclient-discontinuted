class exports.ChannelEntry extends Backbone.View
  template : require('templates/sidebar/channel_entry')

  initialize : ->
    @el = $(@el)
    unless @model.get('metadata')?
      @model.get_metadata()
    @model.bind "change", @on_change

  render : ->
    vals = @model.toJSON()
    console.log vals
    @el.html @template vals
    @

  on_change : =>
    app.debug "the model changed, lets do sth.", @