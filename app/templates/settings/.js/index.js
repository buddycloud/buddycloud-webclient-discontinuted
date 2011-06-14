if(!this.$templates){
  $templates={};
};

 this.$templates.settingsIndex = function (__obj) {
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
      __out.push('<h1>\n  <img src="/public/icons/cog.png" /> Profile Settings\n</h1>\n\n<form action="#settings/save">\n  <div class="f">\n    <label>Jid</label>\n    ');
      __out.push(__sanitize(this.user.escape('jid')));
      __out.push('\n    <small>You cannot change this, sorry.</small>\n  </div>\n\n  <div class="f">\n    <label>First Name</label>\n    <input type="text" value="');
      __out.push(__sanitize(this.user.escape('firstName')));
      __out.push('" />\n    <small>Your full name and email address is shown to other users in your roster.</small>\n  </div>\n\n  <div class="f">\n    <label>Last Name</label>\n    <input type="text" value="');
      __out.push(__sanitize(this.user.escape('lastName')));
      __out.push('" />\n  </div>\n\n  <div class="f">\n    <label>Email address</label>\n    <input type="text" value="');
      __out.push(__sanitize(this.user.escape('email')));
      __out.push('" />\n    <small>\n      We send notifications and password reset messages to this email address, so be careful.\n    </small>\n  </div>\n\n  <div class="f">\n    <label>Description</label>\n    <textarea name="description">');
      __out.push(__sanitize(this.user.escape('description')));
      __out.push('"</textarea>\n    <small>\n      This is your profile description and is visible at the top of your channel.\n    </small>\n  </div>\n\n  <div class="f">\n    <button type="submit">Save Changes</button>\n  </div>\n</form>');
    }).call(this);
    
  }).call(__obj);
  __obj.safe = __objSafe, __obj.escape = __escape;
  return __out.join('');
}