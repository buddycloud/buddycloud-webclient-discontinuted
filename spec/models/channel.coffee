describe 'channel', ->

  it 'should be user', ->
    c = new Channel { node : '/user/ben@ben.com/channel' }
    expect(c.isUserChannel()).toBeTruthy()

    c = new Channel { node : '/user/ben@ben.com/channel' }
    expect(c.isStandalone()).toBeFalsy()
    
  it 'should be standalone', ->

    c = new Channel { node : '/channel/food' }
    expect(c.isStandalone()).toBeTruthy()
    
  it 'should get user jid', ->
    c = new Channel { node : '/user/ben@ben.com/channel' }
    expect(c.getUserJid()).toEqual('ben@ben.com')

    c = new Channel { node : '/user/ben@ben.com/channel@x.com@y.y' }
    expect(c.getUserJid()).toEqual('ben@ben.com')
  
  
  it 'should be not viewable', ->
    c = new Channel { access_model : 'whitelist', subscription : 'pending' }
    expect(c.canView()).toBeFalsy()

    c = new Channel { access_model : 'open', subscription : 'pending' }
    expect(c.canView()).toBeTruthy()
    
