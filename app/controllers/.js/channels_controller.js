(function() {
  var ChannelsController;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  ChannelsController = (function() {
    function ChannelsController() {
      ChannelsController.__super__.constructor.apply(this, arguments);
    }
    __extends(ChannelsController, Backbone.Controller);
    ChannelsController.prototype.routes = {
      "channels": "index",
      "channels/:node": "show"
    };
    ChannelsController.prototype.index = function() {
      app.focusTab('Channels');
      return new ChannelsIndexView({
        el: $("#content"),
        collection: Channels.getStandalone()
      });
    };
    ChannelsController.prototype.show = function(node) {
      var channel;
      channel = Channels.findOrCreateByNode("/channel/" + node);
      channel.markAllAsRead();
      return new ChannelsShowView({
        el: $("#content"),
        model: channel
      });
    };
    return ChannelsController;
  })();
  new ChannelsController;
}).call(this);
