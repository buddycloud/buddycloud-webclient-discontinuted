(function() {
  var Channel;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  Channel = (function() {
    function Channel() {
      this._fetchPosts = __bind(this._fetchPosts, this);;      Channel.__super__.constructor.apply(this, arguments);
    }
    __extends(Channel, Backbone.Model);
    Channel.prototype.initialize = function() {
      this.posts = PostCollection.forChannel(this);
      this.set({
        new_posts: 0
      });
      this.status = null;
      return this.bind('add', __bind(function() {
        return this._incrementNewPosts();
      }, this));
    };
    Channel.prototype.connector = function() {
      return this._connector || (this._connector = new Connector($c.c));
    };
    Channel.prototype.markAllAsRead = function() {
      return this.set({
        new_posts: 0
      });
    };
    Channel.prototype._incrementNewPosts = function() {
      return this.set({
        new_posts: this.getNewPosts() + 1
      });
    };
    Channel.prototype.hasNewPosts = function() {
      return this.getNewPosts() > 0;
    };
    Channel.prototype.getNewPosts = function() {
      if (this.get('new_posts')) {
        return parseInt(this.get('new_posts'));
      } else {
        return 0;
      }
    };
    Channel.prototype.getStatus = function() {
      return new String(this.status);
    };
    Channel.prototype.isLoading = function() {
      return (this.status === null) || (this.status === 'loading');
    };
    Channel.prototype.updateUsers = function() {
      if (this.isUserChannel()) {
        return Users.findOrCreateByJid(this.getUserJid());
      }
    };
    Channel.prototype.getNode = function() {
      return this.get('node');
    };
    Channel.prototype.subscribe = function() {
      this.connector().subscribe(channel, app.currentUser);
      return channel.set({
        subscription: 'subscribed'
      });
    };
    Channel.prototype.unsubscribe = function() {
      this.connector().unsubscribe(channel, app.currentUser);
      return channel.set({
        subscription: null
      });
    };
    Channel.prototype.isSubscribed = function() {
      return this.get('subscription') === 'subscribed';
    };
    Channel.prototype.isWhitelisted = function() {
      return this.get('access_model') === 'whitelist';
    };
    Channel.prototype.canView = function() {
      return this.get('access_model') === 'open';
    };
    Channel.prototype.canPost = function() {
      return (this.get('affiliation') === 'owner') || (this.get('affiliation') === 'publisher') || (this.get('default_affiliation') === 'publisher');
    };
    Channel.prototype.isStandalone = function() {
      return this.getNode().match(/^.channel/);
    };
    Channel.prototype.isUserChannel = function() {
      return this.getNode().match(/^.user/);
    };
    Channel.prototype.getUserJid = function() {
      return this.getNode().match(/user.(.+?)\//)[1];
    };
    Channel.prototype.escapeCreationDate = function() {
      return this.escape('creation_date').replace(/T.+/, '');
    };
    Channel.prototype.hasMetaData = function() {
      return !!this.get('owner');
    };
    Channel.prototype.escapeOwnerNode = function() {
      return this.escape('owner').replace(/@.+/, '');
    };
    Channel.prototype.fetchPosts = function() {
      this.status = 'loading';
      if ($c.connected) {
        return this._fetchPosts();
      } else {
        return $c.bind('connected', this._fetchPosts);
      }
    };
    Channel.prototype._fetchPosts = function() {
      return this.connector().getChannelPosts(this, __bind(function(posts) {
        var p, post, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = posts.length; _i < _len; _i++) {
          post = posts[_i];
          _results.push((p = this.posts.get(post.id)) ? (p.set(post), p.save()) : (p = new Post(post), this.posts.add(p), p.save()));
        }
        return _results;
      }, this), __bind(function(errCode) {
        this.status = errCode;
        return this.trigger('change');
      }, this));
    };
    Channel.prototype.fetchMetadata = function() {
      return this.connector().getMetadata(this, __bind(function(obj) {
        this.set(obj);
        return this.save();
      }, this), __bind(function(errCode) {
        this.set({
          status: errCode
        });
        return this.save();
      }, this));
    };
    Channel.prototype.getPosts = function() {
      this.fetchPosts();
      return this.posts;
    };
    Channel.prototype.getName = function() {
      return this.get('node').replace(/.+\//, '');
    };
    return Channel;
  })();
  this.Channel = Channel;
}).call(this);
