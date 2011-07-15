
# The channel shows channel content
class exports.ChannelView extends Backbone.View
  template : require 'templates/channel/show'

  initialize : =>
    @el = $("<div>").attr id:@cid

  render : =>
    @channel = @model.toJSON()
    console.log "|||", this
    @el.replaceWith nel = $(@template this).attr id:@cid
    @el = nel
    @info = @el.find('.channelDetails')
    console.warn "asasfasfasfasdfasdf", @info, @el, @el.find('.info.button')
    @el.find('.info.button').click => @info.toggleClass('hidden')
    this
