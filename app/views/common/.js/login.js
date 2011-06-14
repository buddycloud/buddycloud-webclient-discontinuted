(function() {
  var CommonLoginView;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  CommonLoginView = (function() {
    function CommonLoginView() {
      this.render = __bind(this.render, this);;
      this.signin = __bind(this.signin, this);;      CommonLoginView.__super__.constructor.apply(this, arguments);
    }
    __extends(CommonLoginView, Backbone.View);
    CommonLoginView.prototype.initialize = function() {
      this.el = $("#auth-container");
      return this.render();
    };
    CommonLoginView.prototype.events = {
      'submit form.signin': 'signin'
    };
    CommonLoginView.prototype.signin = function(e) {
      var jid, password;
      e.preventDefault();
      jid = this.el.find("input[name='jid']").val();
      password = this.el.find("input[name='password']").val();
      if (jid.match(/@/) && password.length > 0) {
        return app.connect(jid, password, true);
      } else {
        return this.flashMessage("Invalid login / password...");
      }
    };
    CommonLoginView.prototype.render = function() {
      this.el.html($templates.commonLogin({
        users: this.collection
      })).hide().fadeIn();
      return this.delegateEvents();
    };
    CommonLoginView.prototype.flashMessage = function(message) {
      var div;
      this.el.find('.form-flash').remove();
      div = $("<div />").addClass('form-flash').text(message);
      div.appendTo(this.el.find('form'));
      return div.hide().slideDown().delay(3000).slideUp();
    };
    return CommonLoginView;
  })();
  this.CommonLoginView = CommonLoginView;
}).call(this);
