describe 'connect', ->
    
  it 'constr', ->
    c = new Connection
    expect(c instanceof Connection).toBeTruthy()
    expect(c.bind).toBeTruthy()
    expect(c.trigger).toBeTruthy()
    
  it 'connect', ->
    c = new Connection

    spyOn(Strophe.Connection.prototype, '_processRequest').andCallFake ->
      true

    c.connect 'ben@localhost', 'fitbutyouknowit'

    expect(c.connected).toBeFalsy()
    expect(c.jid).toEqual('ben@localhost')
    expect(c.password).toEqual('fitbutyouknowit')

  xit 'connecting', ->
    c = new FakedConnection
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
      

