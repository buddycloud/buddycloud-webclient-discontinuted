class UsersController extends Backbone.Controller
  routes :
    "users/:jid" : "show"

  show: (jid) ->
    user = Users.findOrCreateByJid(jid)
    new UsersShowView { model : user }
    
new UsersController
