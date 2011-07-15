gravatar = (mail, opts) ->
    hash = MD5.hexdigest mail.toLowerCase()
    "https://secure.gravatar.com/avatar/#{hash}?" + $.param(opts)

class exports.ChannelEntry extends Backbone.View
  template : require 'templates/sidebar/channel_entry'

  initialize : =>
    @el = $("<div>").attr id:@cid
    @model.get_metadata() unless @model.get('metadata')?
    @model.bind "change", @render

  render : =>
    vals = @model.toJSON()
    console.log ">>>>>>>>>>>>>>>>>>>>>", vals, this
    @channel = vals
    @avatar = gravatar @channel.jid, s:50, d:'retro'
    x = $(@template this).attr id:@cid
    @el = @el.replaceWith(x)
    this

  isPersonal : (a, b) =>
    @channel?.metadata?.owner?.value is @model.jid? and a or b

  isSelected : (a, b) =>
    off and a or b
