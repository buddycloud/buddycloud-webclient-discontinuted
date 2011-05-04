class FriendsController extends Backbone.Controller
  routes :
    "friends" : "index"

  index: (jid) ->
    new FriendsIndexView { collection : $c.roster }
    
new FriendsController
