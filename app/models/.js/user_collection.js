(function() {
  var UserCollection;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  UserCollection = (function() {
    function UserCollection() {
      UserCollection.__super__.constructor.apply(this, arguments);
    }
    __extends(UserCollection, Backbone.Collection);
    UserCollection.prototype.model = User;
    UserCollection.prototype.localStorage = new Store("UserCollection");
    UserCollection.prototype.smartFilter = function(func) {
      var collection;
      collection = new Backbone.Collection;
      collection.model = this.model;
      collection.refresh(this.select(func));
      this.bind('all', __bind(function() {
        return collection.refresh(this.select(func));
      }, this));
      return collection;
    };
    UserCollection.prototype.findFriends = function() {
      return this.smartFilter(function(user) {
        return user.getChannel().isSubscribed();
      });
    };
    UserCollection.prototype.findByGroup = function(group) {
      return this.smartFilter(function(user) {
        return user.get('group') === group;
      });
    };
    UserCollection.prototype.findByJid = function(jid) {
      return this.find(function(user) {
        return user.get('jid') === jid;
      });
    };
    UserCollection.prototype.findOrCreateByJid = function(jid) {
      var user;
      user = null;
      if (this.findByJid(jid)) {
        user = this.findByJid(jid);
      } else {
        user = new User({
          jid: jid
        });
        this.add(user);
      }
      return user;
    };
    return UserCollection;
  })();
  this.UserCollection = UserCollection;
}).call(this);
