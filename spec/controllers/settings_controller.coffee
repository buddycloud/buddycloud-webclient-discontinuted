describe 'settings controller', ->

  it 'should handle the truth', ->
    expect(true).toBeTruthy()

  it 'should exist', ->
    expect(SettingsController).toBeTruthy()

  it 'should instantiate', ->
    x = new SettingsController
    expect(x instanceof SettingsController).toBeTruthy()
    expect(x instanceof Backbone.Controller).toBeTruthy()

  it 'should have index method', ->
    x = new SettingsController
    x.index()

    # Umm..?
    expect(true).toBeTruthy()
