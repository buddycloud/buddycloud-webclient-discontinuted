class UsersController extends Backbone.Controller
  routes :
    "users/:jid" : "show"
    "users/:jid/subscriptions" : "subscriptions"

  show: (jid) ->
    user = Users.findOrCreateByJid(jid)
    new UsersShowView { model : user }
    
  subscriptions: (jid) ->
    user = Users.findOrCreateByJid(jid)
    user.fetchSubscriptions()
    new UsersSubscriptionsView { model : user }
    
new UsersController
