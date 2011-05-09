describe 'list view', ->

  it 'should handle the truth', ->
    expect(true).toBeTruthy()

  it 'should exist', ->
    expect(PostsListView).toBeTruthy()

  it 'should instantiate', ->
    x = new PostsListView { model : new Channel }
    expect(x instanceof PostsListView).toBeTruthy()
    expect(x instanceof Backbone.View).toBeTruthy()

  it 'should have render method', ->
    x = new PostsListView { model : new Channel }
    x.render()

    # Umm..?
    expect(true).toBeTruthy()
