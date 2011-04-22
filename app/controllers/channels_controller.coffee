class ChannelsController extends Backbone.Controller
  routes :
    "channels" : "index"
    "channels/:node" : "show"
    
  index: ->
    new ChannelsIndexView { collection : Channels.getStandalone() }
    
  show: (node) ->
    channel = Channels.findOrCreateByNode("/channel/#{node}")
    new ChannelsShowView { model : channel }
        
new ChannelsController
