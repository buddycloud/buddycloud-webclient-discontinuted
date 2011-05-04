describe 'settings view', ->

  it 'should handle the truth', ->
    expect(true).toBeTruthy()

  it 'should exist', ->
    expect(SettingsView).toBeTruthy()

  it 'should instantiate', ->
    x = new SettingsView
    expect(x instanceof SettingsView).toBeTruthy()
    expect(x instanceof Backbone.View).toBeTruthy()

  it 'should have render method', ->
    x = new SettingsView
    x.render()

    # Umm..?
    expect(true).toBeTruthy()
