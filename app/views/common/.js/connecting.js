(function() {
  var CommonConnectingView;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  CommonConnectingView = (function() {
    function CommonConnectingView() {
      this.render = __bind(this.render, this);;      CommonConnectingView.__super__.constructor.apply(this, arguments);
    }
    __extends(CommonConnectingView, Backbone.View);
    CommonConnectingView.prototype.initialize = function() {
      this.el = $("#auth-container");
      return this.render();
    };
    CommonConnectingView.prototype.render = function() {
      this.el.html($templates.commonConnecting());
      return this.delegateEvents();
    };
    return CommonConnectingView;
  })();
  this.CommonConnectingView = CommonConnectingView;
}).call(this);
