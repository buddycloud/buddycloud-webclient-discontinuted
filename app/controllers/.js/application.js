(function() {
  String.prototype.capitalize = function(){
   return this.replace( /(^|\s)([a-z])/g , function(m,p1,p2){ return p1+p2.toUpperCase(); } );
};;  var Application;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Application = (function() {
    function Application() {
      this.onConnected = __bind(this.onConnected, this);;
      this.onConnecting = __bind(this.onConnecting, this);;
      this.onAuthfail = __bind(this.onAuthfail, this);;
    }
    Application.prototype.connect = function(jid, password, autologin) {
      if (autologin) {
        $c.bind('connected', function() {
          localStorage['jid'] = jid;
          return localStorage['password'] = password;
        });
      }
      return $c.connect(jid, password);
    };
    Application.prototype.focusTab = function(tab) {
      var li, _i, _len, _ref, _results;
      $("#main-tabs li").removeClass('active');
      _ref = $("#main-tabs li");
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        li = _ref[_i];
        _results.push(li.innerHTML.match(tab) ? $(li).addClass('active') : void 0);
      }
      return _results;
    };
    Application.prototype.spinner = function() {
      $("#content").fadeOut();
      $('#spinner').remove();
      return $("<div id='spinner'><img src='public/spinner.gif' /> Connecting...</div>").appendTo('body');
    };
    Application.prototype.removeSpinner = function() {
      $("#content").fadeIn();
      return $('#spinner').remove();
    };
    Application.prototype.signout = function() {
      delete this.currentUser;
      window.location.hash = "";
      Channels.refresh([]);
      Users.refresh([]);
      localStorage.clear();
      $c.unbind();
      if ($c.c) {
        return $c.c.disconnect();
      }
    };
    Application.prototype.start = function() {
      var jid;
      window.Channels = new ChannelCollection;
      window.Channels.fetch();
      window.Users = new UserCollection;
      window.Users.fetch();
      window.Posts = new PostCollection;
      window.Posts.fetch();
      window.Friends = new FriendCollection;
      window.Friends.fetch();
      window.$c = new Connection;
      $c.bind('authfail', this.onAuthfail);
      $c.bind('connecting', this.onConnecting);
      $c.bind('connected', this.onConnected);
      if (jid = localStorage['jid']) {
        this.currentUser = Users.findOrCreateByJid(jid);
        $c.connect(localStorage['jid'], localStorage['password']);
      } else {
        window.location.hash = "";
      }
      return Backbone.history.start();
    };
    Application.prototype.onAuthfail = function() {
      this.removeSpinner();
      return alert("Incorrect username / password");
    };
    Application.prototype.onConnecting = function() {
      if (window.location.hash === "#login") {
        return this.spinner();
      } else {
        return new CommonConnectingView;
      }
    };
    Application.prototype.onConnected = function() {
      console.log("test");
      this.removeSpinner();
      this.currentUser = Users.findOrCreateByJid($c.jid);
      new CommonAuthView;
      return Backbone.history.loadUrl();
    };
    return Application;
  })();
  this.Application = Application;
}).call(this);
