`String.prototype.capitalize = function(){
   return this.replace( /(^|\s)([a-z])/g , function(m,p1,p2){ return p1+p2.toUpperCase(); } );
};`

class Application
  connect: (jid, password, autologin)->
    if autologin
      $c.bind 'connected', ->
        localStorage['jid'] = jid
        localStorage['password'] = password

    $c.connect jid, password
  
  # Focusses the tab specified by it's content, eg focusTab('Home')
  focusTab: (tab) ->
    $("#main-tabs li").removeClass('active')
  
    for li in $("#main-tabs li")
      if li.innerHTML.match(tab)
        $(li).addClass('active')
  
  # Show the loading spinner
  spinner: ->
    $("#content").fadeOut()
    $('#spinner').remove()
    $("<div id='spinner'><img src='public/spinner.gif' /> Connecting...</div>").appendTo 'body'

  # Remove the loading spinner
  removeSpinner: ->
    $("#content").fadeIn()
    $('#spinner').remove()

  signout: ->
    delete @currentUser
    window.location.hash = ""
  
    Channels.refresh []
    Users.refresh []
  
    localStorage.clear()

    # Force disconnect...
    $c.unbind()

    if $c.c
      $c.c.disconnect()

  start: ->
    # Create collections
    window.Channels = new ChannelCollection
    window.Channels.fetch()
  
    window.Users = new UserCollection
    window.Users.fetch()
  
    # Establish xmpp connection
    window.$c = new Connection
  
    $c.bind 'authfail', @onAuthfail
    $c.bind 'connecting', @onConnecting
    $c.bind 'connected', @onConnected

    # Previously logged in and wants autologin
    if jid = localStorage['jid']
      @currentUser = Users.findOrCreateByJid(jid)
      $c.connect(localStorage['jid'], localStorage['password'])
    else
      window.location.hash = ""

    # Start the url router
    Backbone.history.start();  
  
  onAuthfail: =>
    @removeSpinner()

    # view = new CommonLoginView
    # view.render()
    # view.flashMessage("Incorrect username / password")
    # 
    alert("Incorrect username / password")

  onConnecting: =>
    if window.location.hash == "#login"
      @spinner()
    else
      new CommonConnectingView

  onConnected: =>
    @removeSpinner()
    @currentUser = Users.findOrCreateByJid($c.jid)
    new CommonAuthView
    $c.fetchRoster()
    
    # Reload the welcome view
    window.location.hash = "#"
    Backbone.history.loadUrl()

@Application = Application
@app = new Application