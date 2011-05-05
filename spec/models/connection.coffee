describe 'connect', ->
    
  parse = (xml) ->
    $(xml)[0]
    
  FakeConnection = ->
    c = new Connection
    c.c = new Strophe.Connection("")
    c
    
  window.Users = new UserCollection
  
  it 'constr', ->
    c = new Connection
    expect(c instanceof Connection).toBeTruthy()
    expect(c.bind).toBeTruthy()
    expect(c.trigger).toBeTruthy()
    
  it 'should sendPresence after connect', ->
    x = new Connection

    spyOn(Strophe.Connection.prototype, 'connect')
    x.connect()

    spyOn(x.connector, 'announcePresence')
    expect(x.afterConnected()).toBeTruthy()

    expect(x.connector.announcePresence).toHaveBeenCalled()
    
  it 'connect', ->
    c = new Connection

    spyOn(Strophe.Connection.prototype, '_processRequest').andCallFake ->
      true

    c.connect 'ben@localhost', 'fitbutyouknowit'

    expect(c.connected).toBeFalsy()
    expect(c.jid).toEqual('ben@localhost')
    expect(c.password).toEqual('fitbutyouknowit')

  xit 'should getRoster', ->
    xml = parse '''<iq from="ben@diaspora-x.com" to="ben@diaspora-x.com/33995944771303268073133564" id="3190:sendIQ" type="result">
      <query xmlns="jabber:iq:roster">
        <item ask="subscribe" subscription="none" jid="hector@me.com">
          <group>Buddies</group>
        </item>
        <item subscription="both" jid="neustradamus@jabber.org">
          <group>Buddies</group>
        </item>
        <item subscription="both" jid="bnolan@buddycloud.com">
          <group>Buddies</group>
        </item>
        <item subscription="both" jid="simon@buddycloud.com"/>
        <item subscription="both" jid="captainamus@gmail.com"/>
        <item subscription="both" jid="pubsub-bridge@broadcaster.buddycloud.com"/>
        <item subscription="none" jid="imaginator@diaspora-x.com"/>
        <item subscription="from" jid="nolan.frances@diaspora-x.com"/>
        <item subscription="from" jid="pierreroudier@diaspora-x.com"/>
        <item subscription="from" jid="rdsimes@diaspora-x.com"/>
        <item subscription="from" jid="mandrew@diaspora-x.com"/>
        <item subscription="none" jid="chillu@diaspora-x.com"/>
        <item subscription="from" jid="sminnee@diaspora-x.com">
          <group>Buddies</group>
        </item>
      </query>
    </iq>'''

    c = new FakeConnection

    expect(c.roster instanceof UserCollection).toBeTruthy()
    expect(c.roster.length).toEqual(0)
    expect(c.roster.findByGroup('Buddies').length).toEqual(0)

    # XML Fixture
    spyOn(c.c, 'sendIQ').andCallFake (query, success, err) ->
      success(xml)
    spyOn(c, '_parseRoster').andCallThrough()

    # Fetch!
    c.fetchRoster()

    expect(c.c.sendIQ).toHaveBeenCalled()
    expect(c._parseRoster).toHaveBeenCalled()
    expect(c.roster.length).toEqual(13)
    expect(c.roster.findByGroup('Buddies').length).toEqual(4)
    
  xit 'connecting', ->
    c = new Connection
    spied = 
      func = ->
        true
    spyOn(spied, 'func')

    it 'creates', ->
      c.bind 'connecting', func
      c.connect 'ben@localhost', 'fitbutyouknowit'
    
    waits 500
    
    it 'should trigger', ->
      expect(func).toHaveBeenCalled()
      

