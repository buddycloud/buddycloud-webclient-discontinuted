(function() {
  describe('jid', function() {
    it('should get domain', function() {
      var j;
      j = new Jid('bnolan@gmail.com');
      expect(j.getDomain()).toEqual('gmail.com');
      j = new Jid('bnolan@gmail.com/x/y/z');
      expect(j.getDomain()).toEqual('gmail.com');
      j = new Jid('bnolan@gmail.com/x/y/z@blah');
      return expect(j.getDomain()).toEqual('gmail.com');
    });
    it('should get node', function() {
      var j;
      j = new Jid('bnolan@gmail.com');
      expect(j.getNode()).toEqual('bnolan');
      j = new Jid('bnolan@gmail.com/x/y/z@blah');
      return expect(j.getNode()).toEqual('bnolan');
    });
    return it('should be a bc domain', function() {
      var j;
      j = new Jid('bnolan@gmail.com');
      expect(j.buddycloudDomain()).toBeFalsy();
      j = new Jid('bnolan@diaspora-x.com');
      expect(j.buddycloudDomain()).toBeTruthy();
      j = new Jid('bnolan@buddycloud.com');
      return expect(j.buddycloudDomain()).toBeTruthy();
    });
  });
}).call(this);
