gravatar = (mail, opts) ->
    hash = MD5.hexdigest mail.toLowerCase()
    "https://secure.gravatar.com/avatar/#{hash}?" + $.param(opts)

class exports.ChannelEntry extends Backbone.View
  template : require 'templates/sidebar/channel_entry'

  initialize : =>
    @selected = no
    @el = $("<div>").attr id:@cid
    @model.get_metadata() unless @model.get('metadata')?
    @model.bind "change", @render

  render : =>
    @channel = @model.toJSON()
    console.log ">>>>>>>>>>>>>>>>>>>>>", this, @model.toJSON()
    @avatar = gravatar @channel.jid, s:50, d:'retro'
    old = @el; old.replaceWith @el = $(@template this).attr id:@cid
    #@el.parent().remove(@el).prepend(@el) if @isPersonal()
    this

  isPersonal : (a, b) =>
    @channel?.metadata?.owner?.value is @model.jid? and (a ? true) or (b ? false)

  isSelected : (a, b) =>
    @selected and (a ? true) or (b ? false)
