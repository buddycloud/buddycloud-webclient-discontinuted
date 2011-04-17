describe 'jid', ->

  it 'should get domain', ->
    j = new Jid('bnolan@gmail.com')
    expect(j.getDomain()).toEqual('gmail.com')

    j = new Jid('bnolan@gmail.com/x/y/z')
    expect(j.getDomain()).toEqual('gmail.com')

    j = new Jid('bnolan@gmail.com/x/y/z@blah')
    expect(j.getDomain()).toEqual('gmail.com')
    
  it 'should get node', ->
    j = new Jid('bnolan@gmail.com')
    expect(j.getNode()).toEqual('bnolan')

    j = new Jid('bnolan@gmail.com/x/y/z@blah')
    expect(j.getNode()).toEqual('bnolan')

  it 'should be a bc domain', ->
    j = new Jid('bnolan@gmail.com')
    expect(j.buddycloudDomain()).toBeFalsy()

    j = new Jid('bnolan@diaspora-x.com')
    expect(j.buddycloudDomain()).toBeTruthy()

    j = new Jid('bnolan@buddycloud.com')
    expect(j.buddycloudDomain()).toBeTruthy()
  
      