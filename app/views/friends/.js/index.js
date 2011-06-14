(function() {
  var FriendsIndexView;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  FriendsIndexView = (function() {
    function FriendsIndexView() {
      this.render = __bind(this.render, this);;
      this.unsubscribe = __bind(this.unsubscribe, this);;
      this.subscribe = __bind(this.subscribe, this);;      FriendsIndexView.__super__.constructor.apply(this, arguments);
    }
    __extends(FriendsIndexView, Backbone.View);
    FriendsIndexView.prototype.initialize = function() {
      this.template = _.template('\n<h1>Friends</h1>\n\n<ul class="big-friends-list">\n  <% this.collection.each(function(friend){ %>\n    <li>\n      <a href="#channels/<%= friend.getFullName() %>">\n        <%= friend.getName().capitalize() %>\n      </a>\n      <p class="mood">\n        <%= friend.getMood() %>\n      </p>\n    </li>\n  <% }); %>\n</ul>\n\n<h3>Add your friends!</h3>\n\n<p>\n  ...\n</p>');
      this.collection.bind('all', this.render);
      return this.render();
    };
    FriendsIndexView.prototype.events = {
      'click .unsubscribe': 'unsubscribe',
      'click .subscribe': 'subscribe'
    };
    FriendsIndexView.prototype.subscribe = function(e) {};
    FriendsIndexView.prototype.unsubscribe = function(e) {};
    FriendsIndexView.prototype.render = function() {
      this.el.html(this.template(this));
      this.delegateEvents();
      $("#main-tabs li").removeClass('active');
      return $("#main-tabs li:nth-child(3)").addClass('active');
    };
    return FriendsIndexView;
  })();
  this.FriendsIndexView = FriendsIndexView;
}).call(this);
