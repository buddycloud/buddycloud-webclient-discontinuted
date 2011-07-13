{ ChannelEntry } = require('views/sidebar/channel_entry')

# The sidebar shows all channels the user subscribed to
class exports.Sidebar extends Backbone.View
  template : require 'templates/sidebar/show'

  initialize : ->
    $('#sidebar').html @template()
    @el = $('#channels')
    app.collections.user_subscriptions.bind "add", @add_one

  # renders all cached channels
  render : ->
    app.collections.user_subscriptions.each (model) =>
      @add_one(model)

  # add a channel template to the list of channels
  add_one : (model) =>
    @el.append new ChannelEntry("model" : model).render().el