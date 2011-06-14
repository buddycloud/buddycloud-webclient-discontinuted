(function() {
  var UsersShowView;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  UsersShowView = (function() {
    function UsersShowView() {
      this.render = __bind(this.render, this);;
      this.keydown = __bind(this.keydown, this);;      UsersShowView.__super__.constructor.apply(this, arguments);
    }
    __extends(UsersShowView, Backbone.View);
    UsersShowView.prototype.initialize = function() {
      this.collection = this.model.getChannel().getPosts();
      this.model.bind('change', this.render);
      this.model.getChannel().bind('change', this.render);
      return this.render();
    };
    UsersShowView.prototype.events = {
      'submit form.new_activity.status': 'submit',
      'keydown textarea': 'keydown'
    };
    UsersShowView.prototype.keydown = function(e) {
      if (e.keyCode === 13) {
        if (e.metaKey || e.shiftKey) {
          ;
        } else {
          $(e.currentTarget).parents("form").submit();
          return e.preventDefault();
        }
      }
    };
    UsersShowView.prototype.submit = function(e) {
      var form, post;
      e.preventDefault();
      form = $(e.currentTarget);
      post = new Post({
        content: this.el.find('textarea:first').val(),
        in_reply_to: null,
        channel: this.model.getNode(),
        author: app.currentUser.get('jid')
      });
      post.send();
      return form.find('textarea:first').val('').blur();
    };
    UsersShowView.prototype.render = function() {
      this.el.html($templates.usersShow({
        view: this,
        user: this.model,
        channel: this.model.getChannel()
      })).find('.timeago').timeago();
      this.delegateEvents();
      return new PostsListView({
        el: this.el.find('.posts'),
        model: this.model.getChannel()
      });
    };
    return UsersShowView;
  })();
  this.UsersShowView = UsersShowView;
}).call(this);
