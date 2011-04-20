describe 'user', ->

  beforeEach ->
    window.Channels = new ChannelCollection
  
  it 'should have a channel', ->
    u = new User { jid : 'ben@ben.com'}
    expect(u.hasNoChannel()).toBeFalsy()

    u.getChannel().set { status : '404' }
    expect(u.hasNoChannel()).toBeTruthy()

    u.getChannel().set { status : '200' }
    expect(u.hasNoChannel()).toBeFalsy()
    
