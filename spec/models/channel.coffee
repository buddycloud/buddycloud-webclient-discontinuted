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
    
  it 'should have new posts', ->
    c = new Channel { node : '/user/ben@ben.com/channel' }
    expect(c.getNewPosts()).toEqual(0)
    
  it 'should fetchPosts', ->
    arr = [{"id":1303018823207,"content":"Zing zang!","author":"ben@diaspora-x.com","published":"2011-04-17T05:40:23Z","in_reply_to":null,"geoloc_country":"","geoloc_locality":"","geoloc_text":""},{"id":1303019941913,"content":"Sheezy.","author":"ben@diaspora-x.com","published":"2011-04-17T05:59:01Z","in_reply_to":1302745752319,"geoloc_country":"","geoloc_locality":"","geoloc_text":""},{"id":1303020049675,"content":"Testing a new post with some kid cudi - http://www.youtube.com/watch?v=ICaTsTkBPV8","author":"ben@diaspora-x.com","published":"2011-04-17T06:00:49Z","in_reply_to":null,"geoloc_country":"","geoloc_locality":"","geoloc_text":""},{"id":1303020839436,"content":"Love it.","author":"ben@diaspora-x.com","published":"2011-04-17T06:13:59Z","in_reply_to":1303020049675,"geoloc_country":"","geoloc_locality":"","geoloc_text":""},{"id":1303020955611,"content":"Hello.","author":"ben@diaspora-x.com","published":"2011-04-17T06:15:55Z","in_reply_to":1303020049675,"geoloc_country":"","geoloc_locality":"","geoloc_text":""},{"id":1303021042582,"content":"Sheeeeezy","author":"ben@diaspora-x.com","published":"2011-04-17T06:17:22Z","in_reply_to":1302745752319,"geoloc_country":"","geoloc_locality":"","geoloc_text":""},{"id":1303021050661,"content":"This works though?","author":"ben@diaspora-x.com","published":"2011-04-17T06:17:30Z","in_reply_to":null,"geoloc_country":"","geoloc_locality":"","geoloc_text":""},{"id":1303021058695,"content":"This works though?","author":"ben@diaspora-x.com","published":"2011-04-17T06:17:38Z","in_reply_to":null,"geoloc_country":"","geoloc_locality":"","geoloc_text":""}]
    
    c = new Channel { node : '/user/ben@ben.com/channel' }
    spyOn(c._connector, 'getChannelPosts').andCallFake (query, success, err) ->
      success(arr)
      
    c._fetchPosts()

    expect(c.posts.length).toEqual(8)

    # Fetch the same posts again and make sure 'changed' wasn't triggered
    
    spyOn(c.posts.models[0], 'trigger')
    c._fetchPosts()

    waits(10)
    
    runs ->
      expect(c.posts.length).toEqual(8)
      expect(c.posts.models[0].trigger).not.toHaveBeenCalled()
      

    