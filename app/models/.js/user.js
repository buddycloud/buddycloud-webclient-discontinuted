(function() {
  var User;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  User = (function() {
    function User() {
      User.__super__.constructor.apply(this, arguments);
    }
    __extends(User, Backbone.Model);
    User.prototype.initialize = function() {};
    User.prototype.serviceProvider = function() {
      return "pubsub-bridge@broadcaster.buddycloud.com";
    };
    User.prototype.getChannel = function() {
      return Channels.findOrCreateByNode(this.getNode());
    };
    User.prototype.getNode = function() {
      return "/user/" + (this.get('jid')) + "/channel";
    };
    User.prototype.getMood = function() {
      return this.get('mood');
    };
    User.prototype.notFound = function() {
      if (this.getChannel().isLoading()) {
        return false;
      } else {
        return this.getChannel().getStatus().toString() !== '200';
      }
    };
    User.prototype.getJid = function() {
      return this.get('jid');
    };
    User.prototype.getFullName = function() {
      return this.getName().capitalize();
    };
    User.prototype.getName = function() {
      return this.get('jid').toString().replace(/@.+/, '');
    };
    User.prototype.getStatus = function() {
      return (this.get('status') + "").replace(/<.+?>/g, '');
    };
    User.prototype.getAvatar = function() {
      if (this.get('jid').toString().match(/@buddycloud/)) {
        return "http://media.buddycloud.com/channel/54x54/buddycloud.com/" + (this.getName()) + ".png";
      } else {
        return "http://www.gravatar.com/avatar/" + (hex_md5(this.get('jid'))) + "?d=http://diaspora-x.com/public/icons/user.png";
      }
    };
    return User;
  })();
  this.User = User;
}).call(this);
