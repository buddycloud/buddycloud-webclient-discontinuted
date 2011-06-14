(function() {
  var SettingsView;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  SettingsView = (function() {
    function SettingsView() {
      SettingsView.__super__.constructor.apply(this, arguments);
    }
    __extends(SettingsView, Backbone.View);
    SettingsView.prototype.initialize = function() {
      return this.render();
    };
    SettingsView.prototype.events = {
      'submit form': 'onSubmit'
    };
    SettingsView.prototype.onSubmit = function(e) {
      return e.preventDefault();
    };
    SettingsView.prototype.render = function() {
      return this.el.html($templates.settingsIndex({
        user: this.model
      }));
    };
    return SettingsView;
  })();
  this.SettingsView = SettingsView;
}).call(this);
