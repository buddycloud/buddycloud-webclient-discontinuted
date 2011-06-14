(function() {
  describe('application', function() {
    beforeEach(function() {
      return localStorage.clear();
    });
    it('should exist', function() {
      return expect(Application).toBeTruthy();
    });
    it('should instantiate', function() {
      var x;
      x = new Application;
      return expect(x instanceof Application).toBeTruthy();
    });
    it('should reload page onConnect', function() {
      var x;
      x = new Application;
      spyOn(Backbone.history, 'loadUrl');
      spyOn(CommonAuthView.prototype, 'render');
      x.onConnected();
      expect(Backbone.history.loadUrl).toHaveBeenCalled();
      return expect(CommonAuthView.prototype.render).toHaveBeenCalled();
    });
    it('should start', function() {
      window.app = new Application;
      app.start();
      expect(typeof Channels != "undefined" && Channels !== null).toBeTruthy();
      return expect(typeof Users != "undefined" && Users !== null).toBeTruthy();
    });
    it('should have spinner', function() {
      var x;
      x = new Application;
      x.spinner();
      return expect($('#spinner:visible')[0]).toBeTruthy();
    });
    it('should remove spinner', function() {
      var x;
      x = new Application;
      x.spinner();
      x.removeSpinner();
      return expect($('#spinner:visible')[0]).toBeFalsy();
    });
    it('should focusTab', function() {
      var div, x;
      x = new Application;
      div = $("<ul id='main-tabs'><li class='h'>Home</li><li class='b'>Blah</li></ul>");
      div.appendTo('body');
      x.focusTab('Home');
      expect(div.find('li.h.active')[0]).toBeTruthy();
      expect(div.find('li.b.active')[0]).toBeFalsy();
      return div.remove();
    });
    return it('should signout', function() {
      var x;
      x = new Application;
      x.currentUser = new User({
        jid: 'ben@example.com'
      });
      x.signout();
      expect(window.location.hash).toEqual("");
      expect(x.currentUser).toBeFalsy();
      return expect(localStorage['jid']).toBeFalsy();
    });
  });
}).call(this);
