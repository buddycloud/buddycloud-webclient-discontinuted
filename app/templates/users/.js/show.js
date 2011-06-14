if(!this.$templates){
  $templates={};
};

 this.$templates.usersShow = function (__obj) {
  if (!__obj) __obj = {};
  var __out = [], __capture = function(callback) {
    var out = __out, result;
    __out = [];
    callback.call(this);
    result = __out.join('');
    __out = out;
    return __safe(result);
  }, __sanitize = function(value) {
    if (value && value.ecoSafe) {
      return value;
    } else if (typeof value !== 'undefined' && value != null) {
      return __escape(value);
    } else {
      return '';
    }
  }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
  __safe = __obj.safe = function(value) {
    if (value && value.ecoSafe) {
      return value;
    } else {
      if (!(typeof value !== 'undefined' && value != null)) value = '';
      var result = new String(value);
      result.ecoSafe = true;
      return result;
    }
  };
  if (!__escape) {
    __escape = __obj.escape = function(value) {
      return ('' + value)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
    };
  }
  (function() {
    (function() {
      __out.push('<h1 class="channel-name">\n  ');
      __out.push(__sanitize(this.user.getFullName()));
      __out.push('\n</h1>\n');
      if (this.user.notFound()) {
        __out.push('\n  <p class="usermeta">\n    <img src="public/icons/flag.png" /> ');
        __out.push(__sanitize(this.user.getFullName()));
        __out.push(' hasn\'t signed up yet.\n  </p>\n');
      } else if (this.channel.isWhitelisted()) {
        __out.push('\n  <p class="usermeta">\n    <img src="public/icons/users.png" /> ');
        __out.push(__sanitize(this.user.getFullName()));
        __out.push(' only shares with friends.\n  </p>\n');
      } else if (this.channel.hasMetaData()) {
        __out.push('\n  <p class="usermeta">\n    <img src="public/icons/globe_2.png" /> ');
        __out.push(__sanitize(this.user.get('jid')));
        __out.push('\n    <img src="public/icons/clock.png" /> Created ');
        __out.push(__sanitize(this.channel.escapeCreationDate()));
        __out.push('\n    <img src="public/icons/chart_bar.png" /> ');
        __out.push(__sanitize(this.channel.escape('num_subscribers')));
        __out.push(' subscribers\n    |\n    ');
        if (user.getChannel().isSubscribed()) {
          __out.push('\n      <a href="#users/');
          __out.push(__sanitize(this.user.get('jid')));
          __out.push('/unsubscribe">Unfriend</a>\n    ');
        } else {
          __out.push('\n      <a href="#users/');
          __out.push(__sanitize(this.user.get('jid')));
          __out.push('/subscribe">Add as a friend</a>\n    ');
        }
        __out.push('\n  </p>\n  <p class="description">\n    ');
        __out.push(__sanitize(this.channel.escape('description')));
        __out.push('\n  </p>\n');
      } else {
        __out.push('\n  <p class="usermeta">\n    <img src="public/icons/sand.png" />Loading...\n  </p>\n');
      }
      __out.push('\n\n');
      if (this.user.notFound()) {
        __out.push('\n\n<div class="big-notice">\n  <h4>\n    <img src="public/icons/flag.png" class="big-icon" />\n    ');
        __out.push(__sanitize(user.getName().capitalize()));
        __out.push(' hasn\'t signed up yet.\n  </h4>\n\n  <p>\n    We couldn\'t find a channel for ');
        __out.push(__sanitize(user.getName().capitalize()));
        __out.push(', which means\n    they haven\'t signed up yet. You can send an invitation to ');
        __out.push(__sanitize(user.getName().capitalize()));
        __out.push('\n    and we will add them to your friends list when they sign up.\n  </p>\n\n  <button>\n    Send invitation to ');
        __out.push(__sanitize(user.getName().capitalize()));
        __out.push('\n  </button>\n</div>\n\n');
      } else if (this.channel.isWhitelisted()) {
        __out.push('\n\n  <div class="big-notice">\n    <h4>\n      <img src="public/icons/users.png" class="big-icon" />\n      ');
        __out.push(__sanitize(this.user.getName().capitalize()));
        __out.push(' only shares with friends.\n    </h4>\n\n    <p>\n      ');
        __out.push(__sanitize(this.user.getName().capitalize()));
        __out.push(' has configured their privacy settings so that\n      only friends can view or post on their wall. You can add ');
        __out.push(__sanitize(user.getName().capitalize()));
        __out.push('\n      as a friend. Once ');
        __out.push(__sanitize(user.getName().capitalize()));
        __out.push(' has confirmed your friendship, you\n      will be able to see their posts.\n    </p>\n\n    <button>\n      Add ');
        __out.push(__sanitize(this.user.getName().capitalize()));
        __out.push(' as a friend\n    </button>\n  </div>\n\n');
      } else {
        __out.push('\n  ');
        if ((this.channel.hasMetaData()) && (this.channel.canPost())) {
          __out.push('\n    <form action="#" class="new_activity status">\n      <h4>Write on ');
          __out.push(__sanitize(this.user.getName()));
          __out.push('s wall</h4>\n      <textarea cols="40" id="activity_content" name="content" rows="20"></textarea>\n      <input name="commit" type="submit" value="Share" />\n    </form>\n  ');
        }
        __out.push('\n  \n  <div class="posts"></div>\n');
      }
      __out.push('\n\n');
    }).call(this);
    
  }).call(__obj);
  __obj.safe = __objSafe, __obj.escape = __escape;
  return __out.join('');
}