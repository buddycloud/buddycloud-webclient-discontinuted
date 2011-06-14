(function() {
  var Connector;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Connector = (function() {
    function Connector(connection) {
      this.connection = connection;
    }
    Connector.prototype.domain = function() {
      return "buddycloud.com";
    };
    Connector.prototype.pubsubService = function() {
      return "broadcaster." + (this.domain());
    };
    Connector.prototype.pubsubJid = function() {
      return "pubsub-bridge@" + (this.pubsubService());
    };
    Connector.prototype.addUserToRoster = function(jid) {
      return this.connection.send($pres({
        "type": "subscribe",
        "to": jid
      }));
    };
    Connector.prototype.removeUserFromRoster = function(jid) {
      return this.connection.send($pres({
        "type": "unsubscribe",
        "to": jid
      }));
    };
    Connector.prototype.subscribeToChannel = function(channel, user, succ, error) {
      var request;
      request = $iq({
        to: this.pubsubJid(),
        type: 'set'
      }).c('pubsub', {
        xmlns: Strophe.NS.PUBSUB
      }).c('subscribe', {
        node: channel.getNode(),
        jid: user.getJid()
      });
      return this.connection.sendIQ(request, __bind(function(response) {
        if (succ != null) {
          return succ(true);
        }
      }, this), __bind(function(e) {
        if (typeof err != "undefined" && err !== null) {
          return err(e);
        }
      }, this));
    };
    Connector.prototype.getUserSubscriptions = function(user, succ, err) {
      var node, request;
      node = user.getNode();
      request = $iq({
        "to": this.pubsubJid(),
        "type": "get"
      }).c("pubsub", {
        "xmlns": "http://jabber.org/protocol/pubsub"
      }).c("subscriptions");
      return this.connection.sendIQ(request, function(response) {
        var channels, subscription;
        channels = (function() {
          var _i, _len, _ref, _results;
          _ref = $(response).find('subscription');
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            subscription = _ref[_i];
            _results.push({
              jid: $(subscription).attr('jid') + ("@" + (this.domain())),
              description: $(subscription).attr('description')
            });
          }
          return _results;
        }).call(this);
        if (succ != null) {
          return succ(channels);
        }
      }, function(e) {
        if (err != null) {
          return err($(e).find('error').attr('code'));
        }
      });
    };
    Connector.prototype.getMetadata = function(channel, succ, err) {
      var request;
      request = $iq({
        "to": this.pubsubJid(),
        "type": "get"
      }).c("query", {
        "xmlns": "http://jabber.org/protocol/disco#info",
        "node": channel.getNode()
      });
      return this.connection.sendIQ(request, __bind(function(response) {
        var field, key, obj, value, _i, _len, _ref;
        obj = {};
        _ref = $(response).find('x field');
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          field = _ref[_i];
          key = $(field).attr('var').replace(/.+#/, '');
          value = $(field).text();
          obj[key] = value;
        }
        return succ(obj);
      }, this), function(e) {
        if (err != null) {
          return err($(e).find('error').attr('code'));
        }
      });
    };
    Connector.prototype.getChannelPosts = function(channel, succ, err) {
      var request;
      request = $iq({
        to: this.pubsubJid(),
        type: 'get'
      }).c('pubsub', {
        xmlns: Strophe.NS.PUBSUB
      }).c('items', {
        node: channel.getNode()
      });
      return this.connection.sendIQ(request, __bind(function(response) {
        var item, posts;
        posts = (function() {
          var _i, _len, _ref, _results;
          _ref = $(response).find('item');
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            item = _ref[_i];
            _results.push(this._parsePost($(item)));
          }
          return _results;
        }).call(this);
        return succ(posts);
      }, this), __bind(function(e) {
        if (err != null) {
          return err($(e).find('error').attr('code'));
        }
      }, this));
    };
    Connector.prototype.announcePresence = function(user) {
      var maxMessageId, request;
      maxMessageId = "1292405757510";
      request = $pres({
        "to": this.pubsubJid()
      }).c("set", {
        "xmlns": "http://jabber.org/protocol/rsm"
      }).c("after").t(maxMessageId);
      this.connection.send(request);
      this.connection.send($pres().c('status').t('buddycloud channels'));
      this.connection.send($pres().tree());
      this.connection.send($pres({
        "to": this.pubsubJid(),
        "from": user.get('jid')
      }).tree());
      this.connection.send($pres({
        "type": "subscribe",
        "to": this.pubsubJid()
      }).tree());
      return this.connection.send($pres({
        "type": "subscribe",
        "to": this.pubsubJid(),
        "from": user.get('jid')
      }).tree());
    };
    Connector.prototype.onIq = function(stanza) {
      var item, obj, p, posts, _i, _len, _results;
      posts = (function() {
        var _i, _len, _ref, _results;
        _ref = $(stanza).find('item');
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          _results.push(this._parsePost($(item)));
        }
        return _results;
      }).call(this);
      _results = [];
      for (_i = 0, _len = posts.length; _i < _len; _i++) {
        obj = posts[_i];
        _results.push(Posts.get(obj.id) ? void 0 : (p = new Post(obj), Posts.add(p), p.save()));
      }
      return _results;
    };
    Connector.prototype._parsePost = function(item) {
      var post;
      post = {
        id: parseInt(item.find('id').text().replace(/.+:/, '')),
        content: item.find('content').text(),
        author: item.find('author jid').text(),
        published: item.find('published').text()
      };
      if (item.find('in-reply-to')) {
        post.in_reply_to = parseInt(item.find('in-reply-to').attr('ref'));
      }
      if (item.find('geoloc')) {
        post.geoloc_country = item.find('geoloc country').text();
        post.geoloc_locality = item.find('geoloc locality').text();
        post.geoloc_text = item.find('geoloc text').text();
      }
      return post;
    };
    return Connector;
  })();
  this.Connector = Connector;
}).call(this);
