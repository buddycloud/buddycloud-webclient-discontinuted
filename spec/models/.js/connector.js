(function() {
  describe('connector', function() {
    return it('should process iqs', function() {
      var count, x;
      window.Posts = new PostCollection;
      x = new Connector;
      count = 0;
      Posts.bind('add', function() {
        return count++;
      });
      x.onIq($fixtures.connectorFiftyitems);
      expect(Posts.length).toEqual(50);
      expect(count).toEqual(50);
      x.onIq($fixtures.connectorFiftyitems);
      expect(Posts.length).toEqual(50);
      return expect(count).toEqual(50);
    });
  });
}).call(this);
