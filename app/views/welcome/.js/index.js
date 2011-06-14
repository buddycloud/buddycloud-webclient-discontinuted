(function() {
  var WelcomeIndexView;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  WelcomeIndexView = (function() {
    function WelcomeIndexView() {
      WelcomeIndexView.__super__.constructor.apply(this, arguments);
    }
    __extends(WelcomeIndexView, Backbone.View);
    WelcomeIndexView.prototype.initialize = function() {
      console.log("wii");
      return this.render();
    };
    WelcomeIndexView.prototype.render = function() {
      this.el.html($templates.welcomeIndex({
        user: app.currentUser
      }));
      return this._renderPosts();
    };
    WelcomeIndexView.prototype._renderSidebar = function() {
      return this.el.find('.sidebar').html($templates.welcome_sidebar({
        posts: Posts,
        user: app.currentUser,
        friends: Friends
      }));
    };
    WelcomeIndexView.prototype._renderPosts = function() {
      return new PostsListView({
        el: this.el.find('.posts'),
        model: Posts
      });
    };
    return WelcomeIndexView;
  })();
  this.WelcomeIndexView = WelcomeIndexView;
}).call(this);
