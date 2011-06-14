(function() {
  var PostsCommentsView;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  PostsCommentsView = (function() {
    function PostsCommentsView() {
      this.render = __bind(this.render, this);;      PostsCommentsView.__super__.constructor.apply(this, arguments);
    }
    __extends(PostsCommentsView, Backbone.View);
    PostsCommentsView.prototype.initialize = function() {
      this.template = _.template('<div class="comment">\n  <img class="micro avatar" src="<%= reply.getAuthorAvatar() %>" />\n  <p class="content">\n    <a href="#users/<%= reply.getAuthor().get(\'jid\') %>"><%= reply.getAuthorName() %></a> \n    <%= view.formatContent(reply) %>\n  </p>\n  <span class="meta">\n    <span class=\'timeago\' title=\'<%= reply.get(\'published\') %>\'><%= reply.get(\'published\') %></span>\n    <% if(reply.hasGeoloc()){ %>\n      | <%= reply.get(\'geoloc_text\') %>\n    <% } %>\n  </span>\n</div>');
      this.model.bind('change', this.render);
      return this.render();
    };
    PostsCommentsView.prototype.formatContent = function(post) {
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
      return content = content.replace(/\bhttp:\/\/\S+/, function(match) {
        var truncated;
        truncated = match.length < 35 ? match : match.slice(7, 27) + "..." + match.slice(-10, match.length);
        return "<a class='inline-link' href='" + match + "'>" + truncated + "</a>";
      });
    };
    PostsCommentsView.prototype.render = function() {
      this.el.html(this.template({
        reply: this.model,
        view: this
      }));
      return this.delegateEvents();
    };
    return PostsCommentsView;
  })();
  this.PostsCommentsView = PostsCommentsView;
}).call(this);
