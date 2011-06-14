(function() {
  describe('list view', function() {
    it('should handle the truth', function() {
      return expect(true).toBeTruthy();
    });
    it('should exist', function() {
      return expect(PostsListView).toBeTruthy();
    });
    it('should instantiate', function() {
      var x;
      x = new PostsListView({
        model: new Channel
      });
      expect(x instanceof PostsListView).toBeTruthy();
      return expect(x instanceof Backbone.View).toBeTruthy();
    });
    return it('should have render method', function() {
      var x;
      x = new PostsListView({
        model: new Channel
      });
      x.render();
      return expect(true).toBeTruthy();
    });
  });
}).call(this);
