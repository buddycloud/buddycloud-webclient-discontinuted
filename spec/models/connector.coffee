describe 'connector', ->

  it 'should process iqs', ->
    window.Posts = new PostCollection
    
    x = new Connector
    
    count = 0
    Posts.bind 'add', ->
      count++
      
    x.onIq($fixtures.connectorFiftyitems)
    expect(Posts.length).toEqual(50)
    expect(count).toEqual(50)

    # Ensure reprocessing those items doesn't re-add them to the collection
    x.onIq($fixtures.connectorFiftyitems)
    expect(Posts.length).toEqual(50)
    expect(count).toEqual(50)
    