describe 'user', ->

  window.Channels = new ChannelCollection
  
  it 'should have a channel', ->
    u = new User { jid : 'ben@ben.com' }
    expect(u.notFound()).toBeFalsy()

    u.getChannel().status = 404
    expect(u.notFound()).toBeTruthy()

    u.getChannel().status = 200
    expect(u.notFound()).toBeFalsy()
    
  it 'should have mood', ->
    u = new User { jid : 'ben@ben.com' }
    expect(u.getMood()).toBeFalsy()

    u.set { mood : 'Charming' }
    expect(u.getMood()).toEqual('Charming')
    
