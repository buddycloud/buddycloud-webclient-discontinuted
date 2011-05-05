class ChannelsController extends Backbone.Controller
  routes :
    "channels" : "index"
    "channels/:node" : "show"
    
  index: ->
    new ChannelsIndexView { el : $("#content"), collection : Channels.getStandalone() }
    
  show: (node) ->
    channel = Channels.findOrCreateByNode("/channel/#{node}")
    channel.markAllAsRead()
    new ChannelsShowView { el : $("#content"), model : channel }
        
new ChannelsController
