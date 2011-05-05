describe 'index view', ->

  it 'should handle the truth', ->
    expect(true).toBeTruthy()

  it 'should exist', ->
    expect(IndexView).toBeTruthy()

  it 'should instantiate', ->
    x = new IndexView
    expect(x instanceof IndexView).toBeTruthy()
    expect(x instanceof Backbone.View).toBeTruthy()

  it 'should have render method', ->
    x = new IndexView
    x.render()

    # Umm..?
    expect(true).toBeTruthy()
