(function() {
  var ChannelsListView;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  ChannelsListView = (function() {
    function ChannelsListView() {
      this.render = __bind(this.render, this);;      ChannelsListView.__super__.constructor.apply(this, arguments);
    }
    __extends(ChannelsListView, Backbone.View);
    ChannelsListView.prototype.initialize = function() {
      this.el = $("#channels-list");
      this.template = _.template('<% channels.each(function(channel){ %>\n  <li>\n    <b><a href="#channels/<%= channel.getName() %>"><%= channel.getName() %></a></b>\n    <% if (channel.hasNewPosts()){ %>\n      <span><%= channel.getNewPosts() %></span>\n    <% } %>\n  </li>\n<% }); %>');
      this.collection.bind('add', this.render);
      this.collection.bind('change', this.render);
      this.collection.bind('remove', this.render);
      this.collection.bind('refresh', this.render);
      return this.render();
    };
    ChannelsListView.prototype.render = function() {
      this.el.html(this.template({
        channels: this.collection.sortByNewPosts()
      }));
      return this.delegateEvents();
    };
    return ChannelsListView;
  })();
  this.ChannelsListView = ChannelsListView;
}).call(this);
