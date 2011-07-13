class exports.ChannelEntry extends Backbone.View
  template : require 'templates/sidebar/channel_entry'

  initialize : =>
    @el = $(@el)
    unless @model.get('metadata')?
      @model.get_metadata()
    @model.bind "change", @render

  render : =>
    vals = @model.toJSON()
    console.log ">>>>>>>>>>>>>>>>>>>>><", vals, this
    @channel = vals
    @el = $(@template this)
    this

  isPersonal : (a, b) =>
    @model.get('metadata')?.owner.value is @model.get('jid')? and a or b

  isSelected : (a, b) =>
    off and a or b
