(function() {
  var ChannelsIndexView;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  ChannelsIndexView = (function() {
    function ChannelsIndexView() {
      this.render = __bind(this.render, this);;
      this.unsubscribe = __bind(this.unsubscribe, this);;
      this.subscribe = __bind(this.subscribe, this);;
      this.onRemove = __bind(this.onRemove, this);;      ChannelsIndexView.__super__.constructor.apply(this, arguments);
    }
    __extends(ChannelsIndexView, Backbone.View);
    ChannelsIndexView.prototype.initialize = function() {
      this.template = _.template('\n<h1>Subscribed Channels</h1>\n\n<ul class="big-channel-list">\n  <% this.collection.each(function(channel){ %>\n    <li>\n      <a href="#channels/<%= channel.getName() %>">\n        <%= channel.getName().capitalize() %>\n      </a>\n      <p class="description">\n        <%= channel.escape(\'description\') %>\n      </p>\n      <span data-id="<%= channel.id %>" class="remove inline-action" title="Remove this channel from my favourites"><img src="/public/icons/trash.png" /></span>\n    </li>\n  <% }); %>\n</ul>\n\n<h3>Discover more channels</h3>\n\n<p>\n  Channels are places to discuss a topic with anyone who is interested. Anyone can join a channel, \n  and you can see everyones comments.\n</p>');
      this.collection.bind('all', this.render);
      return this.render();
    };
    ChannelsIndexView.prototype.events = {
      'click .unsubscribe': 'unsubscribe',
      'click .subscribe': 'subscribe',
      'click .remove': "onRemove"
    };
    ChannelsIndexView.prototype.onRemove = function(e) {
      var id;
      id = $(e.currentTarget).attr('data-id');
      return this.collection.get(id).destroy();
    };
    ChannelsIndexView.prototype.subscribe = function(e) {};
    ChannelsIndexView.prototype.unsubscribe = function(e) {};
    ChannelsIndexView.prototype.render = function() {
      this.el.html(this.template(this));
      return this.delegateEvents();
    };
    return ChannelsIndexView;
  })();
  this.ChannelsIndexView = ChannelsIndexView;
}).call(this);
