(function() {
  var FriendCollection;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  FriendCollection = (function() {
    function FriendCollection() {
      FriendCollection.__super__.constructor.apply(this, arguments);
    }
    __extends(FriendCollection, Backbone.Collection);
    FriendCollection.prototype.model = User;
    FriendCollection.prototype.localStorage = new Store("FriendCollection");
    FriendCollection.prototype.smartFilter = function(func) {
      var collection;
      collection = new Backbone.Collection;
      collection.model = this.model;
      collection.refresh(this.select(func));
      this.bind('all', __bind(function() {
        return collection.refresh(this.select(func));
      }, this));
      return collection;
    };
    FriendCollection.prototype.findByGroup = function(group) {
      return this.smartFilter(function(user) {
        return user.get('group') === group;
      });
    };
    return FriendCollection;
  })();
  this.FriendCollection = FriendCollection;
}).call(this);
