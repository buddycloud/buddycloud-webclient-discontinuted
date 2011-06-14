if(!this.$templates){
  $templates={};
};

 this.$templates.commonLogin = function (__obj) {
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
      __out.push('<form action="#signin" class="signin">\n  <div class="f">\n    <label for="jid">Login</label>\n    <input name="jid" size="30" style="width: 180px" type="text" />\n    <small style="display: none">\n      <input checked="checked" name="remember_me" type="checkbox" value="1" /> Remember me\n    </small>\n  </div>\n\n  <div class="f">\n    <label for="password">Password</label>\n    <input name="password" size="30" style="width: 120px" type="password" />\n    <small>\n      <a href="#forgot">Forgot your password?</a>\n    </small>\n  </div>\n\n  <div class="f">\n    <button type="submit">Sign in</button>\n  </div>\n</form>\n');
    }).call(this);
    
  }).call(__obj);
  __obj.safe = __objSafe, __obj.escape = __escape;
  return __out.join('');
}