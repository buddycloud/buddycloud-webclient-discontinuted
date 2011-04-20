describe 'channel', ->

  window.$c = new Connection

  it 'should have status', ->
    c = new Channel { node : '/user/ben@ben.com/channel' }
    expect(c.status).toEqual(null)
    
    c.fetchPosts()
    expect(c.status).toEqual('loading')
    
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
    
  it 'should be isWhitelisted', ->
    c = new Channel { access_model : 'whitelist', subscription : 'pending' }
    expect(c.isWhitelisted()).toBeTruthy()

    c = new Channel { access_model : 'open', subscription : 'pending' }
    expect(c.isWhitelisted()).toBeFalsy()
  
  it 'should be loading', ->
    c = new Channel { node : '/user/ben@ben.com/channel' }
    expect(c.isLoading()).toBeTruthy()

    c.fetchPosts()
    expect(c.isLoading()).toBeTruthy()
    
    c.status = 404
    expect(c.isLoading()).toBeFalsy()

    c.status = '404'
    expect(c.isLoading()).toBeFalsy()

    c.status = '200'
    expect(c.isLoading()).toBeFalsy()
    