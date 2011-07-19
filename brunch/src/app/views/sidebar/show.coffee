{ ChannelOverView } = require('views/sidebar/more')
{ ChannelEntry } = require('views/sidebar/channel_entry')
{ ChannelView } = require('views/channel/show')

# The sidebar shows all channels the user subscribed to
class exports.Sidebar extends Backbone.View
  template : require 'templates/sidebar/show'

  initialize : =>
    # default's not visible due to nice animation
    $('#sidebar').html @template()
    @el = $('#channels')
    $('#more_channels').hide()
    app.views.overview ?= new ChannelOverView
    @hidden = yes
    @channel = {}
    @current_channel = null
    app.collections.user_subscriptions.bind "add", @add_one

  # renders all cached channels
  render : =>
    app.collections.user_subscriptions.each (model) =>
      @add_one(model)

  # add a channel template to the list of channels
  add_one : (model) =>
    # FIXME  this just display main channel
    return unless /\/user\/.+@.+\/channel/.test(model.id)
    console.error "MODEL", model, model.toJSON()
    @el.append new ChannelEntry({model}).render().el
    @el.css(left:-@el.width()) if @hidden

    if model.get "metadata"
      @channel[model.cid] ?= new ChannelView {model}
      @setCurrentChannel(model.cid) unless @current_channel
    model.bind 'change', =>
      @channel[model.cid] ?= new ChannelView {model}
      @setCurrentChannel(model.cid) unless @current_channel

  setCurrentChannel : (id) =>
    @current_channel?.selected = no
    @current_channel?.render()
    @current_channel = @channel[id]
    $('#content').html @current_channel.el
    @current_channel.selected = yes
    @current_channel.render()

  # sliding in animation
  moveIn: (t = 200) =>
    @el.animate(left:"0px", t)
    $('#more_channels').delay(t * 0.1).fadeIn()
    @hidden = no

  # sliding out animation
  moveOut: (t = 200) =>
    @el.animate(left:"-#{@el.width()}px", t)
    $('#more_channels').delay(t * 0.1).fadeOut()
    @hidden = yes
