class ChannelsController extends Backbone.Controller
  routes :
    "channels" : "index"
    "channels/:node" : "show"
    
  index: ->
    new ChannelsIndexView { collection : Channels.getStandalone() }
    
  show: (node) ->
    channel = Channels.findOrCreateByNode("/channel/#{node}")
    channel.markAllAsRead()
    new ChannelsShowView { model : channel }
        
new ChannelsController
