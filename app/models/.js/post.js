(function() {
  var Post;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Post = (function() {
    function Post() {
      Post.__super__.constructor.apply(this, arguments);
    }
    __extends(Post, Backbone.Model);
    Post.prototype.initializer = function() {};
    Post.prototype.canReply = function() {
      return true;
    };
    Post.prototype.serviceProvider = function() {
      return "pubsub-bridge@broadcaster.buddycloud.com";
    };
    Post.prototype.isReply = function() {
      return (this.get('in_reply_to') !== null) && (!isNaN(this.get('in_reply_to')));
    };
    Post.prototype.hasGeoloc = function() {
      return (typeof this.get('geoloc_text') === 'string') && (this.get('geoloc_text') !== "");
    };
    Post.prototype.isUserChannel = function() {
      return this.get('channel').match(/^.user/);
    };
    Post.prototype.hasReplies = function() {
      return this.getReplies().any();
    };
    Post.prototype.getReplies = function() {
      return _(this.collection.filter(__bind(function(post) {
        return post.get('in_reply_to') === this.id;
      }, this)));
    };
    Post.prototype.valid = function() {
      return this._validate(this.attributes) === true;
    };
    Post.prototype._validate = function(attributes) {
      if ((typeof attributes.content !== 'string') || (attributes.content === "")) {
        return "Can't have empty content";
      } else {
        return true;
      }
    };
    Post.prototype.getAuthor = function() {
      return Users.findOrCreateByJid(this.get('author'));
    };
    Post.prototype.getAuthorName = function() {
      return this.getAuthor().getName();
    };
    Post.prototype.getAuthorAvatar = function() {
      return this.getAuthor().getAvatar();
    };
    Post.prototype.send = function() {
      var errors;
      if (errors = this.valid()) {
        return this._send();
      } else {
        return alert("not sending.. seems invalid.");
      }
    };
    Post.prototype._send = function() {
      var request;
      request = $iq({
        "to": this.serviceProvider(),
        "type": "set"
      }).c("pubsub", {
        "xmlns": "http://jabber.org/protocol/pubsub"
      }).c("publish", {
        "node": this.get('channel')
      }).c("item").c("entry", {
        "xmlns": "http://www.w3.org/2005/Atom"
      }).c("content", {
        "type": "text"
      }).t(this.get("content")).up().c("author").c("jid", {
        "xmlns": "http://buddycloud.com/atom-elements-0"
      }).t(this.get("author")).up().up();
      if (this.isReply()) {
        request.c("in-reply-to", {
          "xmlns": "http://purl.org/syndication/thread/1.0",
          "ref": this.get('in_reply_to')
        }).up();
      }
      return $c.c.sendIQ(request, __bind(function(response) {
        console.log('response');
        return console.log(response);
      }, this), function(err) {
        console.log('error!');
        return console.log(err);
      });
    };
    return Post;
  })();
  this.Post = Post;
}).call(this);
