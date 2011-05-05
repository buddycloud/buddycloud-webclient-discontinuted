describe 'application', ->

  beforeEach ->
    localStorage.clear()
    
  it 'should exist', ->
    expect(Application).toBeTruthy()

  it 'should instantiate', ->
    x = new Application
    expect(x instanceof Application).toBeTruthy()

  it 'should reload page onConnect', ->
    x = new Application
    spyOn(Backbone.history, 'loadUrl')
    spyOn(CommonAuthView.prototype, 'render')
    x.onConnected()
    expect(Backbone.history.loadUrl).toHaveBeenCalled()
    expect(CommonAuthView.prototype.render).toHaveBeenCalled()
    
    
  it 'should start', ->
    window.app = new Application
    app.start()
    
    expect(Channels?).toBeTruthy()
    expect(Users?).toBeTruthy()
    
  it 'should have spinner', ->
    x = new Application
    x.spinner()
    expect($('#spinner:visible')[0]).toBeTruthy()

  it 'should remove spinner', ->
    x = new Application
    x.spinner()
    x.removeSpinner()
    expect($('#spinner:visible')[0]).toBeFalsy()

  it 'should focusTab', ->
    x = new Application

    div = $("<ul id='main-tabs'><li class='h'>Home</li><li class='b'>Blah</li></ul>")
    div.appendTo 'body'
    
    x.focusTab('Home')
    expect(div.find('li.h.active')[0]).toBeTruthy()
    expect(div.find('li.b.active')[0]).toBeFalsy()
    
    div.remove()
    
  it 'should signout', ->
    x = new Application
    x.currentUser = new User { jid : 'ben@example.com' }
    x.signout()
    
    expect(window.location.hash).toEqual("")
    expect(x.currentUser).toBeFalsy()
    expect(localStorage['jid']).toBeFalsy()

