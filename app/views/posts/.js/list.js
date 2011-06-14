(function() {
  var PostsListView;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  PostsListView = (function() {
    function PostsListView() {
      this.render = __bind(this.render, this);;
      this.updatePost = __bind(this.updatePost, this);;
      this.removePost = __bind(this.removePost, this);;
      this.addPost = __bind(this.addPost, this);;
      this.keydown = __bind(this.keydown, this);;      PostsListView.__super__.constructor.apply(this, arguments);
    }
    __extends(PostsListView, Backbone.View);
    PostsListView.prototype.initialize = function() {
      this.template = _.template('<div class="activity" data-id="<%= post.id %>">\n  <div class="grid_1">\n    <img class="thumb avatar" src="<%= post.getAuthorAvatar() %>" />\n  </div>\n  <div class="grid_4">\n    <h4>\n      <a href="#users/<%= post.getAuthor().get(\'jid\') %>"><%= post.getAuthorName() %> </a>\n    </h4>\n    <p class="content">\n      <%= helpers.formatContent(post) %>\n    </p>\n    <p class="meta">\n      <span class=\'timeago\' title=\'<%= post.get(\'published\') %>\'><%= post.get(\'published\') %></span>\n      <% if (post.canReply()){ %>\n        | <a href="#" onclick="$(this).parents(\'.activity\').find(\'form\').show().find(\'textarea\').focus(); return false">Comment</a>\n      <% } %>\n      <% if(post.hasGeoloc()){ %>\n        | <%= post.get(\'geoloc_text\') %>\n      <% } %>\n    </p>\n  \n    <div class="comments">\n      <div class="chevron">&diams;</div>\n    </div>\n\n    <form class="new_activity reply" action="#">\n      <input type="hidden" name="in_reply_to" value="<%= post.id %>" />\n      <textarea name="content"></textarea>\n      <input type="submit" value="Comment" />\n    </form>\n\n  </div>\n  <div class="clear"></div>\n</div>');
      this.collection = this.model.getPosts();
      this.collection.bind('add', this.addPost);
      this.collection.bind('change', this.updatePost);
      this.collection.bind('remove', this.removePost);
      this.collection.bind('refresh', this.render);
      return this.render();
    };
    PostsListView.prototype.events = {
      'submit form': 'submit',
      'keydown textarea': 'keydown'
    };
    PostsListView.prototype.formatContent = function(post) {
      var content;
      content = post.escape('content');
      content = content.replace(/\#\S+?\b/, function(match) {
        var channel;
        channel = match.slice(1, 100);
        return "<a class='inline-channel' href='#channels/" + channel + "'>#" + channel + "</a>";
      });
      content = content.replace(/\b\S+?@\S+\.\S+?\b/, function(match) {
        var jid;
        jid = new Jid(match);
        if (jid.buddycloudDomain()) {
          return "<a class='inline-jid' href='#users/" + (jid.getNode()) + "'>" + (jid.getNode()) + "</a>";
        } else {
          return "<a class='inline-email' href='mailto:" + match + "'>" + match + "</a>";
        }
      });
      return content = content.replace(/\bhttp:\/\/\S+\b/, function(match) {
        var truncated;
        truncated = match.length < 35 ? match : match.slice(7, 27) + "..." + match.slice(-10, match.length);
        return "<a class='inline-link' href='" + match + "'>" + truncated + "</a>";
      });
    };
    PostsListView.prototype.keydown = function(e) {
      if (e.keyCode === 13) {
        if (e.metaKey || e.shiftKey) {
          ;
        } else {
          $(e.currentTarget).parents("form").submit();
          return e.preventDefault();
        }
      }
    };
    PostsListView.prototype.submit = function(e) {
      var form, post;
      e.preventDefault();
      form = $(e.currentTarget);
      post = new Post({
        content: form.find('textarea:first').val(),
        in_reply_to: form.find("input[name='in_reply_to']").val(),
        channel: this.model.getNode(),
        author: app.currentUser.get('jid')
      });
      form.find('textarea:first').val('');
      form.hide();
      return post.send();
    };
    PostsListView.prototype.addPost = function(post) {
      var div, reply, _i, _len, _ref, _results;
      if (post.isReply()) {
        div = this.el.find("div[data-id='" + (post.get('in_reply_to')) + "']");
        this.addReply(div, post);
        return div.find('.comments').show();
      } else {
        div = $(this.template({
          helpers: this,
          post: post
        }));
        div.find('.timeago').timeago();
        div.insertBefore(this.el.find("div:first"));
        div.find('a.inline-link').embedly({
          method: 'afterParent',
          maxWidth: 400
        });
        if (post.hasReplies()) {
          div.find('.comments').show();
        } else {
          div.find('.comments').hide();
        }
        _ref = post.getReplies().value();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          reply = _ref[_i];
          _results.push(this.addReply(div, reply));
        }
        return _results;
      }
    };
    PostsListView.prototype.addReply = function(div, reply) {
      var el;
      el = $("<div />");
      el.appendTo(div.find('.comments'));
      return new PostsCommentsView({
        model: reply,
        el: el
      });
    };
    PostsListView.prototype.removePost = function(post) {
      return console.log("posts#list#removePost not implemented!");
    };
    PostsListView.prototype.updatePost = function(post) {
      return console.log("posts#list#removePost not implemented!");
    };
    PostsListView.prototype.render = function() {
      var post, _i, _len, _ref;
      this.el.html("<div />");
      _ref = this.collection.notReplies().slice(0, 50);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        post = _ref[_i];
        this.addPost(post);
      }
      return this.delegateEvents();
    };
    return PostsListView;
  })();
  this.PostsListView = PostsListView;
}).call(this);
