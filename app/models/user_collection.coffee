class UserCollection extends Backbone.Collection
  model: User
  
  localStorage: new Store("UserCollection")

  smartFilter : (func) ->
    collection = new Backbone.Collection
    collection.model = @model
    collection.refresh(@select(func))
    @bind 'all', =>
      collection.refresh(@select(func))
    collection
    
  # Returns a list of users that I am subscribed to
  findFriends : ->
    @smartFilter (user) ->
      user.getChannel().isSubscribed()
    
  findByGroup : (group) ->
    @smartFilter (user) ->
      user.get('group') == group
      
  findByJid : (jid) ->
    @find (user) ->
      user.get('jid') == jid
      
  findOrCreateByJid : (jid) ->
    user = null

    if @findByJid(jid)
      user = @findByJid(jid)
    else
      user = new User {
        jid : jid
      }
      @add user
      # user.save()

    user
  
@UserCollection = UserCollection  