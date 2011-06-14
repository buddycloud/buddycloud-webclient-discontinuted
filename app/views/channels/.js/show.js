(function() {
  var ChannelsShowView;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  ChannelsShowView = (function() {
    function ChannelsShowView() {
      this.render = __bind(this.render, this);;
      this.unsubscribe = __bind(this.unsubscribe, this);;
      this.subscribe = __bind(this.subscribe, this);;
      this.keydown = __bind(this.keydown, this);;      ChannelsShowView.__super__.constructor.apply(this, arguments);
    }
    __extends(ChannelsShowView, Backbone.View);
    ChannelsShowView.prototype.initialize = function() {
      this.model.fetchMetadata();
      this.collection = this.model.getPosts();
      this.template = _.template('<div class="channel-info">\n</div>\n\n  <p class="subscribe-buttons">\n    <% if(channel.isSubscribed()){ %>\n      <button class="unsubscribe">Unsubscribe</button>\n    <% }else{ %>\n      <button class="subscribe">Subscribe</button>\n    <% } %>\n  </p>\n\n  <h1 class="channel-name">\n    <%= channel.getName().capitalize() %>\n  </h1>\n  <p class="usermeta">\n    <% if(channel.hasMetaData()){ %>\n      <img src="public/icons/user.png" /> Owned by <%= channel.escapeOwnerNode() %>\n      <img src="public/icons/clock.png" /> Created <%= channel.escapeCreationDate() %>\n      <img src="public/icons/chart_bar.png" /> <%= channel.escape(\'num_subscribers\') %> subscribers \n      <img src="public/icons/net_comp.png" /> Hosted by <%= channel.pubsubServiceDomain() %>\n    <% } else { %>\n      <img src="public/icons/sand.png" />Loading...\n    <% } %>\n  </p>\n  <p class="description">\n    <%= channel.escape(\'description\') %>\n  </p>\n</div>\n\n<% if(channel.canPost()){ %>\n  <form action="#" class="new_activity status">\n    <h4>New post</h4>\n    <textarea cols="40" id="activity_content" name="content" rows="20"></textarea>\n    <input name="commit" type="submit" value="Share" />\n  </form>\n<% } %>\n  \n<div class="posts"></div>');
      this.model.bind('change', this.render);
      return this.render();
    };
    ChannelsShowView.prototype.events = {
      'submit form.new_activity.status': 'submit',
      'keydown textarea': 'keydown',
      'click button.unsubscribe': 'unsubscribe',
      'click button.subscribe': 'subscribe'
    };
    ChannelsShowView.prototype.keydown = function(e) {
      if (e.keyCode === 13) {
        if (e.metaKey || e.shiftKey) {
          ;
        } else {
          $(e.currentTarget).parents("form").submit();
          return e.preventDefault();
        }
      }
    };
    ChannelsShowView.prototype.submit = function(e) {
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
    ChannelsShowView.prototype.subscribe = function(e) {
      e.preventDefault();
      return this.model.subscribe();
    };
    ChannelsShowView.prototype.unsubscribe = function(e) {
      e.preventDefault();
      return this.model.unsubscribe();
    };
    ChannelsShowView.prototype.render = function() {
      this.el.html(this.template({
        channel: this.model
      }));
      this.delegateEvents();
      new PostsListView({
        el: this.el.find('.posts'),
        model: this.model
      });
      $("#main-tabs li").removeClass('active');
      return $("#main-tabs li:nth-child(2)").addClass('active');
    };
    return ChannelsShowView;
  })();
  this.ChannelsShowView = ChannelsShowView;
}).call(this);
