class exports.ChannelEntry extends Backbone.View
  template : require('templates/sidebar/channel_entry')
  
  initialize : ->
    @el = $(@el)
  
  render : ->
    vals = @model.toJSON()
    @el.html @template vals
    @