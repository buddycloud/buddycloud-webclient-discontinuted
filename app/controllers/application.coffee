`String.prototype.capitalize = function(){
   return this.replace( /(^|\s)([a-z])/g , function(m,p1,p2){ return p1+p2.toUpperCase(); } );
};`

app = {}

app.connect = ->
  # Spinner!
  app.spinner()

  window.location.hash = "connecting"

app.currentUser = null

app.spinner = ->
  $("#content").empty()
  $("<div id='spinner'><img src='public/spinner.gif' /> Connecting...</div>").appendTo 'body'

app.showLog = ->
  $("#log").show()
  
app.signedIn = (jid) ->
  $("#spinner").remove()
  
  if not Users.findByJid(jid)
    user = new User { jid : jid }
    Users.add user
    
  app.currentUser = Users.findByJid(jid)
  
  # window.location.hash = app.afterConnect
  
  new CommonAuthView
  
app.signout = ->
  window.location.hash = ""
  $("#spinner").remove()
  
  Posts.refresh []
  Users.refresh []
  
  localStorage.clear()
  
  window.location.reload()
  
  try
    window.$c.c.disconnect()
  catch e
    # ...
    
  window.$c = null
  

app.start = ->

  # Create collections
  window.Channels = new ChannelCollection
  window.Channels.fetch()

  if jid = localStorage['jid']
    # Set the currentUser
    app.currentUser = Users.findOrCreateByJid(jid)

    # Establish xmpp connection
    window.$c = new Connection(localStorage['jid'], localStorage['password'])
    
    $c.bind 'connecting', ->
      new CommonConnectingView
      
    $c.bind 'connected', ->
      app.signedIn($c.jid)
      
    # $c.bind 'disconnect', app.afterConnect
    
    $c.connect()
  else
    window.location.hash = ""

  # Start the url router
  Backbone.history.start();  


@app = app
