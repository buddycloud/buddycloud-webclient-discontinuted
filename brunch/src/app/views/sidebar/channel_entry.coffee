
class exports.ChannelEntry extends Backbone.View
  template : require 'templates/sidebar/channel_entry'

  initialize : =>
    @selected = no
    @el = $("<div>").attr id:@cid
    @model.get_metadata() unless @model.get('metadata')?
    @model.bind "change", @render

  render : =>
    @avatar = @model.avatar
    @channel = @model.toJSON()
    console.log ">>>>>>>>>>>>>>>>>>>>>", this, @model.toJSON()
    old = @el; old.replaceWith @el = $(@template this).attr id:@cid
    @el.click =>
        app.sidebar.setCurrentChannel @model.cid
    #@el.parent().remove(@el).prepend(@el) if @isPersonal()
    this

  isPersonal : (a, b) =>
    @channel?.metadata?.owner?.value is @model.jid? and (a ? true) or (b ? false)

  isSelected : (a, b) =>
    @selected and (a ? true) or (b ? false)
