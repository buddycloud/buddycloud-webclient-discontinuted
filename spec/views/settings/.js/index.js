(function() {
  describe('settings view', function() {
    it('should handle the truth', function() {
      return expect(true).toBeTruthy();
    });
    it('should exist', function() {
      return expect(SettingsView).toBeTruthy();
    });
    it('should instantiate', function() {
      var x;
      x = new SettingsView({
        model: new User
      });
      expect(x instanceof SettingsView).toBeTruthy();
      return expect(x instanceof Backbone.View).toBeTruthy();
    });
    it('should render', function() {
      var x;
      x = new SettingsView({
        el: $("<div />"),
        model: new User({
          jid: 'ben@ben.com'
        })
      });
      x.render();
      return expect(true).toBeTruthy();
    });
    return it('should submit', function() {
      var el, x;
      el = $("<div />");
      x = new SettingsView({
        el: el,
        model: new User({
          jid: 'ben@ben.com'
        })
      });
      x.render();
      el.find('form').submit();
      return expect(true).toBeTruthy();
    });
  });
}).call(this);
