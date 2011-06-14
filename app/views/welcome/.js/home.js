(function() {
  var WelcomeHomeView;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  WelcomeHomeView = (function() {
    function WelcomeHomeView() {
      this.render = __bind(this.render, this);;
      this.signup = __bind(this.signup, this);;      WelcomeHomeView.__super__.constructor.apply(this, arguments);
    }
    __extends(WelcomeHomeView, Backbone.View);
    WelcomeHomeView.prototype.initialize = function() {
      this.el = $("#content");
      console.log("wch");
      this.template = _.template('  \n    <div class="grid_12">\n      <h1>\n        A social network that is friends with the other social networks\n      </h1>\n    </div>\n\n    <div class="grid_6">\n      <p>\n        This is a branch of <a href="https://github.com/diaspora/diaspora">Diaspora</a> that supports the <a href="http://activitystrea.ms/">Activity Streams</a> standard.\n        This is the primary diaspora*x server for public use, or you can <a href="http://github.com/bnolan/diaspora-x2">run your own</a>.\n      </p>\n\n      <h2><span>Sign Up</span></h2>\n\n      <div>\n        <p>\n          <small>\n            Its free, forever.\n          </small>\n        </p>\n\n        <form action="#signup" class="signup">\n\n          <div class="f">\n            <label for="jid">Login</label>\n            <input name="jid" size="30" style="width: 120px" type="text" /> @ diaspora-x.com\n          </div>\n\n          <div class="f">\n            <label for="email">Email</label>\n            <input name="email" size="30" type="text" value="" />\n          </div>\n\n          <div class="f">\n            <label for="password">Password</label>\n            <input name="password" size="30" style="width: 80px" type="password" />\n          </div>\n\n          <div class="f">\n            <label for="password_confirmation">Confirm Password</label>\n            <input name="password_confirmation" size="30" style="width: 80px" type="password" />\n          </div>\n\n          <div class="f"><input id="user_submit" name="commit" type="submit" value="Sign up" /></div>\n        </form>\n      </div>\n      \n      \n    </div>');
      return this.render();
    };
    WelcomeHomeView.prototype.events = {
      'submit form.signup': 'signup'
    };
    WelcomeHomeView.prototype.signup = function(e) {
      var jid, password;
      jid = this.el.find(".signin input[name='jid']").val();
      password = this.el.find(".signin input[name='password']").val();
      if (jid.match(/@/) && password.length > 0) {
        localStorage['jid'] = jid;
        localStorage['password'] = password;
        app.connect();
      } else {
        alert("Invalid login / password...");
      }
      return e.preventDefault();
    };
    WelcomeHomeView.prototype.render = function() {
      $('ul.tabs li').hide();
      this.el.html(this.template({
        users: this.collection
      })).hide().fadeIn();
      this.delegateEvents();
      return new CommonLoginView;
    };
    return WelcomeHomeView;
  })();
  this.WelcomeHomeView = WelcomeHomeView;
}).call(this);
