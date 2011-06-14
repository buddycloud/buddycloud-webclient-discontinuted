(function() {
  /*
  Initial router when a user visits the index page
  */  var WelcomeController;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  WelcomeController = (function() {
    function WelcomeController() {
      WelcomeController.__super__.constructor.apply(this, arguments);
    }
    __extends(WelcomeController, Backbone.Controller);
    WelcomeController.prototype.routes = {
      "": "index",
      "logout": "logout"
    };
    WelcomeController.prototype.logout = function() {
      return app.signout();
    };
    WelcomeController.prototype.index = function() {
      var user;
      app.focusTab('Home');
      $("#spinner").remove();
      if (app.currentUser) {
        user = app.currentUser;
        return new WelcomeIndexView({
          el: $("#content")
        });
      } else {
        return new WelcomeHomeView({
          el: $("#content")
        });
      }
    };
    return WelcomeController;
  })();
  new WelcomeController;
}).call(this);
