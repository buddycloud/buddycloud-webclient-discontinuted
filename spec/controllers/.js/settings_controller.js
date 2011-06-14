(function() {
  describe('settings controller', function() {
    beforeEach(function() {
      window.app = new Application;
      return app.currentUser = new User({
        jid: "ben@example.com"
      });
    });
    it('should handle the truth', function() {
      return expect(true).toBeTruthy();
    });
    it('should exist', function() {
      return expect(SettingsController).toBeTruthy();
    });
    it('should instantiate', function() {
      var x;
      x = new SettingsController;
      expect(x instanceof SettingsController).toBeTruthy();
      return expect(x instanceof Backbone.Controller).toBeTruthy();
    });
    return it('should have index method', function() {
      var x;
      x = new SettingsController;
      x.index();
      return expect(true).toBeTruthy();
    });
  });
}).call(this);
