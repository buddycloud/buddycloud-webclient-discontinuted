`String.prototype.capitalize = function(){
   return this.replace( /(^|\s)([a-z])/g , function(m,p1,p2){ return p1+p2.toUpperCase(); } );
};`

app = {}

app.connect = (jid, password, autologin)->
  window.location.hash = "#home"
  
  if autologin
    localStorage['jid'] = jid
    localStorage['password'] = password

  $c.connect jid, password
  
app.currentUser = null

# app.spinner = ->
#   $("#content").empty()
#   $("<div id='spinner'><img src='public/spinner.gif' /> Connecting...</div>").appendTo 'body'
# 

# app.showLog = ->
#   $("#log").show()
#   
  
app.signout = ->
  delete app.currentUser
  window.location.hash = ""
  
  Channels.refresh []
  Users.refresh []
  
  localStorage.clear()
  
  try
    window.$c.c.disconnect()
  catch e
    # ...
  

app.start = ->

  # Create collections
  window.Channels = new ChannelCollection
  window.Channels.fetch()

  # Establish xmpp connection
  window.$c = new Connection
  
  $c.bind 'connecting', ->
    new CommonConnectingView
    
  $c.bind 'connected', ->
    jid = $c.jid
    
    alert "?"

    # if not Users.findByJid(jid)
    #   user = new User { jid : jid }
    #   Users.add user
    # 
    app.currentUser = Users.findOrCreateByJid(jid)
  
    window.location.hash = "#home"

    alert app.currentUser
    
    new CommonAuthView

  # $c.bind 'disconnect', ->
  #   ....
    
  # Previously logged in and wants autologin
  if jid = localStorage['jid']
    app.connect localStorage['jid'], localStorage['password']
    app.currentUser = Users.findOrCreateByJid(jid)
    $c.connect(localStorage['jid'], localStorage['password'])
  else
    window.location.hash = ""

  # Start the url router
  Backbone.history.start();  

@app = app
