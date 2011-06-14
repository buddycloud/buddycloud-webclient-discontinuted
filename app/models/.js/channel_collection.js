(function() {
  var ChannelCollection;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  ChannelCollection = (function() {
    function ChannelCollection() {
      ChannelCollection.__super__.constructor.apply(this, arguments);
    }
    __extends(ChannelCollection, Backbone.Collection);
    ChannelCollection.prototype.model = Channel;
    ChannelCollection.prototype.initialize = function() {
      return this.localStorage = new Store("ChannelCollection");
    };
    ChannelCollection.prototype.findByNode = function(node) {
      return this.find(function(channel) {
        return channel.get('node') === node;
      });
    };
    ChannelCollection.prototype.getStandalone = function() {
      var channels;
      channels = new ChannelCollection;
      channels.refresh(this.select(function(channel) {
        return (channel.isStandalone()) && (channel.isSubscribed());
      }));
      return channels;
    };
    ChannelCollection.prototype.sortByNewPosts = function() {
      this.comparator = function(c) {
        return 0 - c.getNewPosts();
      };
      this.sort({
        silent: true
      });
      return this;
    };
    ChannelCollection.prototype.findOrCreateByNode = function(node) {
      var channel;
      channel = null;
      if (this.findByNode(node)) {
        channel = this.findByNode(node);
      } else {
        channel = new Channel({
          node: node
        });
        this.add(channel);
        channel.save();
      }
      return channel;
    };
    return ChannelCollection;
  })();
  this.ChannelCollection = ChannelCollection;
}).call(this);
