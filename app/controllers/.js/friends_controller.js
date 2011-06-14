(function() {
  var FriendsController;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  FriendsController = (function() {
    function FriendsController() {
      FriendsController.__super__.constructor.apply(this, arguments);
    }
    __extends(FriendsController, Backbone.Controller);
    FriendsController.prototype.routes = {
      "friends": "index"
    };
    FriendsController.prototype.index = function(jid) {
      return new FriendsIndexView({
        el: $("#content"),
        collection: $c.roster
      });
    };
    return FriendsController;
  })();
  new FriendsController;
}).call(this);
