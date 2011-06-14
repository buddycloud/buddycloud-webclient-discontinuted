(function() {
  var CommonAuthView;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  CommonAuthView = (function() {
    function CommonAuthView() {
      this.render = __bind(this.render, this);;      CommonAuthView.__super__.constructor.apply(this, arguments);
    }
    __extends(CommonAuthView, Backbone.View);
    CommonAuthView.prototype.initialize = function() {
      this.el = $("#auth-container");
      return this.render();
    };
    CommonAuthView.prototype.render = function() {
      this.el.html($templates.commonAuth({
        user: app.currentUser
      }));
      return this.delegateEvents();
    };
    return CommonAuthView;
  })();
  this.CommonAuthView = CommonAuthView;
}).call(this);
