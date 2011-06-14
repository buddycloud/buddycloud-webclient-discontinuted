(function() {
  var UsersController;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  UsersController = (function() {
    function UsersController() {
      UsersController.__super__.constructor.apply(this, arguments);
    }
    __extends(UsersController, Backbone.Controller);
    UsersController.prototype.routes = {
      "users/:jid": "show"
    };
    UsersController.prototype.show = function(jid) {
      var user;
      app.focusTab('Friends');
      user = Users.findOrCreateByJid(jid);
      return new UsersShowView({
        el: $("#content"),
        model: user
      });
    };
    return UsersController;
  })();
  new UsersController;
}).call(this);
