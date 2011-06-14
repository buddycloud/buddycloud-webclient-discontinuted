(function() {
  var UsersListView;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  UsersListView = (function() {
    function UsersListView() {
      this.render = __bind(this.render, this);;      UsersListView.__super__.constructor.apply(this, arguments);
    }
    __extends(UsersListView, Backbone.View);
    UsersListView.prototype.initialize = function() {
      this.el = $("#friends-list");
      this.template = _.template('<% users.each(function(user){ %>\n  <li>\n    <img class="micro avatar" src="<%= user.getAvatar() %>" />\n    <b><a href="#users/<%= user.get(\'jid\') %>"><%= user.getName() %></a></b>\n  </li>\n<% }); %>');
      this.collection.bind('all', this.render);
      return this.render();
    };
    UsersListView.prototype.render = function() {
      this.el.html(this.template({
        users: this.collection
      }));
      return this.delegateEvents();
    };
    return UsersListView;
  })();
  this.UsersListView = UsersListView;
}).call(this);
