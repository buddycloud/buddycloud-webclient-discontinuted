class UsersController extends Backbone.Controller
  routes :
    "users/:jid" : "show"
    "users/:jid/subscribe" : "subscribe"
    "users/:jid/unsubscribe" : "unsubscribe"
    
  subscribe: (jid) ->
    user = Users.findOrCreateByJid(jid)
    user.getChannel().subscribe()
    window.location.hash = "#users/#{user.get('jid')}"

  unsubscribe: (jid) ->
    user = Users.findOrCreateByJid(jid)
    user.getChannel().unsubscribe()
    window.location.hash = "#users/#{user.get('jid')}"

  show: (jid) ->
    user = Users.findOrCreateByJid(jid)
    # user.subscribe()
    # user.fetchPosts()
    new UsersShowView { model : user }
    
new UsersController
