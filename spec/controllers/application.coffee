describe 'application', ->

  it 'should exist', ->
    expect(Application).toBeTruthy()

  it 'should instantiate', ->
    expect(app instanceof Application).toBeTruthy()

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

  