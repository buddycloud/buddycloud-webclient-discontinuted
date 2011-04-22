`String.prototype.capitalize = function(){
   return this.replace( /(^|\s)([a-z])/g , function(m,p1,p2){ return p1+p2.toUpperCase(); } );
};`

app = {}

app.connect = (jid, password, autologin)->
  if autologin
    $c.bind 'connected', ->
      localStorage['jid'] = jid
      localStorage['password'] = password

  $c.connect jid, password
  
app.currentUser = null

app.spinner = ->
  $("#content").fadeOut()
  $('#spinner').remove()
  $("<div id='spinner'><img src='public/spinner.gif' /> Connecting...</div>").appendTo 'body'

app.removeSpinner = ->
  $("#content").fadeIn()
  $('#spinner').remove()

# app.showLog = ->
#   $("#log").show()
#   
  
app.signout = ->
  delete app.currentUser
  window.location.hash = ""
  
  Channels.refresh []
  Users.refresh []
  
  localStorage.clear()

  # Force disconnect...
  $c.unbind()
  if $c.c
    $c.c.disconnect()

app.start = ->

  # Create collections
  window.Channels = new ChannelCollection
  window.Channels.fetch()
  
  window.Users = new UserCollection
  window.Users.fetch()
  
  # Establish xmpp connection
  window.$c = new Connection
  
  $c.bind 'authfail', ->
    app.removeSpinner()

    # view = new CommonLoginView
    # view.render()
    # view.flashMessage("Incorrect username / password")
    # 
    alert("Incorrect username / password")

  $c.bind 'connecting', ->
    if window.location.hash == "#login"
      app.spinner()
    else
      new CommonConnectingView
    
  $c.bind 'connected', ->
    app.removeSpinner()
    app.currentUser = Users.findOrCreateByJid($c.jid)
    new CommonAuthView

    $c.fetchRoster()
    Backbone.history.loadUrl()

  # $c.bind 'disconnect', ->
  #   ....
    
  # Previously logged in and wants autologin
  if jid = localStorage['jid']
    app.currentUser = Users.findOrCreateByJid(jid)
    $c.connect(localStorage['jid'], localStorage['password'])
  else
    window.location.hash = ""

  # Start the url router
  Backbone.history.start();  

@app = app
