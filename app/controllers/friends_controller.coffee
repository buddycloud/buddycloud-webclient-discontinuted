class FriendsController extends Backbone.Controller
  routes :
    "friends" : "index"

  index: (jid) ->
    new FriendsIndexView { el : $("#content"), collection : $c.roster }
    
new FriendsController
