{ gravatar } = require('helper')

class exports.User extends Backbone.Model
  defaults :
    display_name : "Bob Kelso"
    jid : "bob.kelso@sacredheart.com"
    logged_in : no

  initialize : ->

  avatar: ->
    gravatar @get('jid'), s:50, d:'retro'

  getNode: ->
    "/user/#{@get('jid')}/channel"

  log_in : ->
    setTimeout =>
      @trigger "logged_in"
    , 1500