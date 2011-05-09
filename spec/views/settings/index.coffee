describe 'settings view', ->

  it 'should handle the truth', ->
    expect(true).toBeTruthy()

  it 'should exist', ->
    expect(SettingsView).toBeTruthy()

  it 'should instantiate', ->
    x = new SettingsView { model : new User }
    expect(x instanceof SettingsView).toBeTruthy()
    expect(x instanceof Backbone.View).toBeTruthy()

  it 'should render', ->
    x = new SettingsView { el : $("<div />"), model : new User { jid : 'ben@ben.com' }}
    x.render()
    expect(true).toBeTruthy()

  it 'should submit', ->
    el = $("<div />")

    x = new SettingsView { el : el, model : new User { jid : 'ben@ben.com' }}
    x.render()

    el.find('form').submit()

    # Umm..?
    expect(true).toBeTruthy()
