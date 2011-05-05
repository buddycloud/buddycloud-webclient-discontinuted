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
