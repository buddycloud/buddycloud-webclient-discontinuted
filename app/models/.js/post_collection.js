(function() {
  var PostCollection;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  PostCollection = (function() {
    function PostCollection() {
      PostCollection.__super__.constructor.apply(this, arguments);
    }
    __extends(PostCollection, Backbone.Collection);
    PostCollection.prototype.model = Post;
    PostCollection.prototype.localStorage = new Store("PostCollection");
    PostCollection.prototype.comparator = function(post) {
      return post.get('published');
    };
    PostCollection.prototype.notReplies = function() {
      return this.filter(__bind(function(post) {
        return !post.get('in_reply_to');
      }, this));
    };
    PostCollection.prototype.getPosts = function() {
      return this;
    };
    return PostCollection;
  })();
  PostCollection.forChannel = function(model) {
    var collection, unique;
    unique = "channel-" + (model.getNode());
    collection = new PostCollection;
    collection.localStorage = new Store("PostCollection-" + unique);
    collection.fetch();
    return collection;
  };
  PostCollection.forUser = function(model) {
    var collection, unique;
    unique = "user-" + (model.getNode());
    collection = new PostCollection;
    collection.localStorage = new Store("PostCollection-" + unique);
    collection.fetch();
    return collection;
  };
  this.PostCollection = PostCollection;
}).call(this);
