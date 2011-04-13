class ChannelsController extends Backbone.Controller
  routes :
    "channels/:node" : "show"
    
  show: (node) ->
    channel = Channels.findOrCreateByNode("/channel/#{node}")
    new ChannelsShowView { model : channel }
        
new ChannelsController
