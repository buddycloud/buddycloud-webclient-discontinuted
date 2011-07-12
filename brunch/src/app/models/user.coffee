class exports.User extends Backbone.Model
  defaults : 
    gravatar_url : "http://www.gravatar.com/avatar/09dbf9c8bf6ff0738d2dd83c832d1f93?s=50"
    display_name : "Bob Kelso"
    jid : "bob.kelso@sacredheart.com"
    logged_in : false
  
  initialize : ->
    
  getNode: ->
    "/user/#{@get('jid')}/channel"  
  
  log_in : ->
    setTimeout =>
      @trigger "logged_in"
    , 1500