class UsersController extends Backbone.Controller
  routes :
    "users/:jid" : "show"

  show: (jid) ->
    app.focusTab('Friends')
    user = Users.findOrCreateByJid(jid)
    new UsersShowView { el : $("#content"), model : user }
    
new UsersController
