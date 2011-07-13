{ ChannelEntry } = require('views/sidebar/channel_entry')

# The sidebar shows all channels the user subscribed to
class exports.Sidebar extends Backbone.View
  template : require 'templates/sidebar/show'

  initialize : =>
    # default's not visible due to nice animation
    $('#sidebar').html @template()
    @el = $('#channels')
    $('#more_channels').hide()
    @hidden = yes
    app.collections.user_subscriptions.bind "add", @add_one

  # renders all cached channels
  render : =>
    app.collections.user_subscriptions.each (model) =>
      @add_one(model)

  # add a channel template to the list of channels
  add_one : (model) =>
    # FIXME just display main channel
    return unless /\/user\/.+@.+\/channel/.test(model.id)
    @el.append new ChannelEntry("model" : model).render().el
    @el.css(left:-@el.width()) if @hidden


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