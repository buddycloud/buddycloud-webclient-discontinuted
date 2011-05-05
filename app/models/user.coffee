class User extends Backbone.Model
  initialize: ->

  serviceProvider: ->
    "pubsub-bridge@broadcaster.buddycloud.com"

  getChannel: ->
    Channels.findOrCreateByNode @getNode()

  getNode: ->
    "/user/#{@get('jid')}/channel"
    
  getMood: ->
    @get('mood')
    
  notFound: ->
    if @getChannel().isLoading()
      false
    else
      @getChannel().getStatus().toString() != '200'
    
  getJid: ->
    @get('jid')
    
  getFullName: ->
    @getName().capitalize()
    
  getName: ->
    @get('jid').toString().replace /@.+/, ''

  getStatus: ->
    (@get('status') + "").replace(/<.+?>/g,'')

  getAvatar: ->
    if @get('jid').toString().match /@buddycloud/
      "http://media.buddycloud.com/channel/54x54/buddycloud.com/#{@getName()}.png"
    else
      "http://www.gravatar.com/avatar/#{hex_md5(@get('jid'))}?d=http://diaspora-x.com/public/icons/user.png"
    
this.User = User

