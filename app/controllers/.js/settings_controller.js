(function() {
  var SettingsController;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  SettingsController = (function() {
    function SettingsController() {
      SettingsController.__super__.constructor.apply(this, arguments);
    }
    __extends(SettingsController, Backbone.Controller);
    SettingsController.prototype.routes = {
      "settings": "index"
    };
    SettingsController.prototype.index = function() {
      app.focusTab('Settings');
      return new SettingsView({
        el: $('#content'),
        model: app.currentUser
      });
    };
    return SettingsController;
  })();
  this.SettingsController = SettingsController;
  new SettingsController;
}).call(this);
