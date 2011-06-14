(function() {
  describe('connect', function() {
    var FakeConnection, parse;
    parse = function(xml) {
      return $(xml)[0];
    };
    FakeConnection = function() {
      var c;
      c = new Connection;
      c.c = new Strophe.Connection("");
      return c;
    };
    window.Users = new UserCollection;
    it('constr', function() {
      var c;
      c = new Connection;
      expect(c instanceof Connection).toBeTruthy();
      expect(c.bind).toBeTruthy();
      return expect(c.trigger).toBeTruthy();
    });
    it('should sendPresence after connect', function() {
      var x;
      x = new Connection;
      spyOn(Strophe.Connection.prototype, 'connect');
      x.connect();
      spyOn(x.connector, 'announcePresence');
      expect(x.afterConnected()).toBeTruthy();
      return expect(x.connector.announcePresence).toHaveBeenCalled();
    });
    it('connect', function() {
      var c;
      c = new Connection;
      spyOn(Strophe.Connection.prototype, '_processRequest').andCallFake(function() {
        return true;
      });
      c.connect('ben@localhost', 'fitbutyouknowit');
      expect(c.connected).toBeFalsy();
      expect(c.jid).toEqual('ben@localhost');
      return expect(c.password).toEqual('fitbutyouknowit');
    });
    xit('should getRoster', function() {
      var c, xml;
      xml = parse('<iq from="ben@diaspora-x.com" to="ben@diaspora-x.com/33995944771303268073133564" id="3190:sendIQ" type="result">\n  <query xmlns="jabber:iq:roster">\n    <item ask="subscribe" subscription="none" jid="hector@me.com">\n      <group>Buddies</group>\n    </item>\n    <item subscription="both" jid="neustradamus@jabber.org">\n      <group>Buddies</group>\n    </item>\n    <item subscription="both" jid="bnolan@buddycloud.com">\n      <group>Buddies</group>\n    </item>\n    <item subscription="both" jid="simon@buddycloud.com"/>\n    <item subscription="both" jid="captainamus@gmail.com"/>\n    <item subscription="both" jid="pubsub-bridge@broadcaster.buddycloud.com"/>\n    <item subscription="none" jid="imaginator@diaspora-x.com"/>\n    <item subscription="from" jid="nolan.frances@diaspora-x.com"/>\n    <item subscription="from" jid="pierreroudier@diaspora-x.com"/>\n    <item subscription="from" jid="rdsimes@diaspora-x.com"/>\n    <item subscription="from" jid="mandrew@diaspora-x.com"/>\n    <item subscription="none" jid="chillu@diaspora-x.com"/>\n    <item subscription="from" jid="sminnee@diaspora-x.com">\n      <group>Buddies</group>\n    </item>\n  </query>\n</iq>');
      c = new FakeConnection;
      expect(c.roster instanceof UserCollection).toBeTruthy();
      expect(c.roster.length).toEqual(0);
      expect(c.roster.findByGroup('Buddies').length).toEqual(0);
      spyOn(c.c, 'sendIQ').andCallFake(function(query, success, err) {
        return success(xml);
      });
      spyOn(c, '_parseRoster').andCallThrough();
      c.fetchRoster();
      expect(c.c.sendIQ).toHaveBeenCalled();
      expect(c._parseRoster).toHaveBeenCalled();
      expect(c.roster.length).toEqual(13);
      return expect(c.roster.findByGroup('Buddies').length).toEqual(4);
    });
    return xit('connecting', function() {
      var c, func, spied;
      c = new Connection;
      spied = func = function() {
        return true;
      };
      spyOn(spied, 'func');
      it('creates', function() {
        c.bind('connecting', func);
        return c.connect('ben@localhost', 'fitbutyouknowit');
      });
      waits(500);
      return it('should trigger', function() {
        return expect(func).toHaveBeenCalled();
      });
    });
  });
}).call(this);
