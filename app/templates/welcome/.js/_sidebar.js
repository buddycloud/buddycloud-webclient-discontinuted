if(!this.$templates){
  $templates={};
};

 this.$templates.welcome_sidebar = function (__obj) {
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
      __out.push('<p>\n  This is a very early beta version, and it\'s pretty rough, but thanks for trying it out and helping me iron out the bugs!<br /><br />\nI\'ve tried to strip out as many unnecessary functions as possible, and as such, may have removed some pretty vital features. The goal for D-X is to create a social network that can act as a replacement for the core facebook functionality of messaging people and sharing content. We don\'t have photo hosting, event planning or \'checkins\', but we should have enough so that you can tell jokes, share stories and communicate with your friends.<br /><br />\n</p>\n\n<h3>What\'s new?</h3>\n\n<p>\n  Added a new home page with this message on it. Posted on reddit.com/r/diaspora to see if they want\n  to test out the new version. Removed legacy buddycloud channel code to make it compatible with\n  the distributed XEP. Added specs for the application and connection classes.\n</p>\n\n<h3>\n  Stats\n</h3>\n\n<div class="grid_2">\n  <a class="statsblock" href="#posts">\n    <b>');
      __out.push(__sanitize(this.posts.length));
      __out.push('</b>\n    <span>Posts</span>\n  </a>\n</div>\n\n<div class="grid_2">\n  <a class="statsblock" href="#posts">\n    <b>');
      __out.push(__sanitize(this.friends.length));
      __out.push('</b>\n    <span>Friends</span>\n  </a>\n</div>\n');
    }).call(this);
    
  }).call(__obj);
  __obj.safe = __objSafe, __obj.escape = __escape;
  return __out.join('');
}