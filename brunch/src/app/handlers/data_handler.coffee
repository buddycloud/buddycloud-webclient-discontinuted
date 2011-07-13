class exports.DataHandler

  constructor : (@connector, @connection) ->
    _.extend @, Backbone.Events
    @user = app.current_user
    @connection.addHandler @on_iq, null, 'iq'
    @getMetadata = @connector.getMetadata

  get_user_subscriptions : ->
    @connector.getUserSubscriptions @user, (subscriptions) =>
      @trigger 'on_user_subscriptions_sync', subscriptions
      app.debug "SUBSCRIPTIONS", subscriptions
    , =>
      app.debug "gus_error", arguments


  on_iq : (stanza) =>
    app.debug "onIq", stanza, $(stanza).find('item')
    posts = for item in $(stanza).find('item')
      @_parse_post($(item))


    app.debug "posts", posts
    # for obj in posts
    #   if Posts.get(obj.id)
    #     # do nothing
    #   else
    #     p = new Post(obj)
    #     Posts.add(p)
    #     p.save()
    return true

  _parse_post : (item) ->
    post = {
      id : parseInt(item.find('id').text().replace(/.+:/,''))
      content : item.find('content').text()
      author : item.find('author jid').text()
      published : item.find('published').text()
    }

    if item.find 'in-reply-to'
      post.in_reply_to = parseInt(item.find('in-reply-to').attr('ref'))

    if item.find 'geoloc'
      post.geoloc_country = item.find('geoloc country').text()
      post.geoloc_locality = item.find('geoloc locality').text()
      post.geoloc_text = item.find('geoloc text').text()

    post