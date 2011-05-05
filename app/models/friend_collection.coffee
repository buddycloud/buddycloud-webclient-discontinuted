class FriendCollection extends Backbone.Collection
  model: User
  
  localStorage: new Store("FriendCollection")

  smartFilter : (func) ->
    collection = new Backbone.Collection
    collection.model = @model
    collection.refresh(@select(func))
    @bind 'all', =>
      collection.refresh(@select(func))
    collection
    
  findByGroup : (group) ->
    @smartFilter (user) ->
      user.get('group') == group
      
  # findByJid : (jid) ->
  #   @find (user) ->
  #     user.get('jid') == jid
  #     
  # findOrCreateByJid : (jid) ->
  #   user = null
  # 
  #   if @findByJid(jid)
  #     user = @findByJid(jid)
  #   else
  #     user = new User {
  #       jid : jid
  #     }
  #     @add user
  #     # user.save()
  # 
  #   user
  # 

@FriendCollection = FriendCollection