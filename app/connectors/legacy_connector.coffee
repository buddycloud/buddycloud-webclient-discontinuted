# #
# #
# # This is the legacy buddycloud connector for connecting to the pre-XEP buddycloud servers.
# #
# #
# class LegacyConnector extends Connector
#   # Only buddycloud afaik
#   domain: ->
#     "buddycloud.com"
# 
#   # The broadcaster
#   pubsubService: ->
#     "broadcaster.#{@domain()}"
# 
#   # The pubsub bridge jid
#   pubsubJid: ->
#     "pubsub-bridge@#{@pubsubService()}"
# 
#   # Add a user to your roster
#   addUserToRoster: (jid) ->
#     @connection.send($pres( { "type" : "subscribe", "to" : jid } ))
# 
#   # Remove a user from your roster
#   removeUserFromRoster: (jid) ->
#     @connection.send($pres( { "type" : "unsubscribe", "to" : jid } ))
# 
# 
#   #
#   # Subscription request
#   #
#   subscribeToChannel: (channel, user, succ, error) ->
#     request = $iq( { to : @pubsubJid(), type : 'set' })
#       .c('pubsub', { xmlns: Strophe.NS.PUBSUB })
#       .c('subscribe', { node: channel.getNode(), jid : user.getJid() })
#     
#     @connection.sendIQ(
#       request
#       (response) =>
#         if succ?
#           succ true
#       (e) =>
#         if err?
#           err e
#     )
# 
#   # Get the subscriptions for a user, calls succ with an array of hashes of channels
#   getUserSubscriptions: (user, succ, err) ->
#     node = user.getNode()
#     
#     request = $iq({"to" : @pubsubJid(), "type":"get"})
#       .c("pubsub", {"xmlns":"http://jabber.org/protocol/pubsub"})
#       .c("subscriptions")
# 
#     # Request..
#     @connection.sendIQ(
#       request
#       (response) ->
#         channels = for subscription in $(response).find('subscription')
#           {
#             jid : $(subscription).attr('jid') + "@#{@domain()}"
#             description : $(subscription).attr('description')
#           }
#         if succ?
#           succ(channels)
#       (e) ->
#         if err?
#           err($(e).find('error').attr('code'))
#     )
#   
#   # Get metadata, calls succ with a hash of metadata
#   getMetadata: (channel, succ, err)->
#     request = $iq( { "to" : @pubsubJid(), "type" : "get" })
#       .c( "query", { "xmlns" : "http://jabber.org/protocol/disco#info", "node" : channel.getNode() })
# 
#     @connection.sendIQ(
#       request,
#       (response) =>
#         # Flatten the namespaced fields into a hash
#         obj = {}
#         for field in $(response).find('x field')
#           key = $(field).attr('var').replace(/.+#/,'')
#           value = $(field).text()
#           obj[key] = value
#         succ(obj)
#       (e) ->
#         if err?
#           err($(e).find('error').attr('code'))
#     )
# 
#   # Get channel posts, calls succ with a array of hashes of posts
#   getChannelPosts: (channel, succ, err) ->
#     request = $iq({ to : @pubsubJid(), type : 'get' })
#       .c('pubsub', { xmlns : Strophe.NS.PUBSUB })
#       .c('items', { node : channel.getNode() })
#       
#     @connection.sendIQ(
#       request,
#       (response) =>
#         posts = for item in $(response).find('item')
#           @_parsePost($(item))
# 
#         succ(posts)
#       (e) =>
#         if err?
#           err($(e).find('error').attr('code'))
#     )
#     
#   # Sends a presence stanza to the server, subscribing to new IQs
#   announcePresence: (user) ->
#     maxMessageId = "1292405757510"
# 
#     # Todo - find out which one of these works and delete the rest
#     request = $pres( { "to" : @pubsubJid() } )
#       .c("set", {"xmlns":"http://jabber.org/protocol/rsm"})
#       .c("after").t(maxMessageId)
#     @connection.send request
#     @connection.send($pres().c('status').t('buddycloud channels'))
#     @connection.send($pres().tree())
#     @connection.send($pres( { "to" : @pubsubJid(), "from" : user.get('jid') } ).tree())
#     @connection.send($pres( { "type" : "subscribe", "to" : @pubsubJid() } ).tree())
#     @connection.send($pres( { "type" : "subscribe", "to" : @pubsubJid(), "from" : user.get('jid') } ).tree())
# 
#   # Takes an <item /> stanza and returns a hash of it's attributes
#   _parsePost : (item) ->
#     post = { 
#       id : parseInt(item.find('id').text().replace(/.+:/,''))
#       content : item.find('content').text() 
#       author : item.find('author jid').text()
#       published : item.find('published').text()
#     }
# 
#     if item.find 'in-reply-to'
#       post.in_reply_to = parseInt(item.find('in-reply-to').attr('ref'))
# 
#     if item.find 'geoloc'
#       post.geoloc_country = item.find('geoloc country').text()
#       post.geoloc_locality = item.find('geoloc locality').text()
#       post.geoloc_text = item.find('geoloc text').text()
# 
#     post
# 
# 
#   # getChannel: (node) ->
#   #   id = @c.getUniqueId("LM")
#   # 
#   #   stanza = $iq({"id":id, "to":PUBSUB_BRIDGE, "type":"get"})
#   #     .c("pubsub", {"xmlns":"http://jabber.org/protocol/pubsub"})
#   #     .c("items", {"node":node})
#   #     .c("set", {"xmlns":"http://jabber.org/protocol/rsm"})
#   #     .c("after").t("100")
#   # 
#   #   # Request..
#   #   @c.send(stanza.tree());
#   # 
#   # 
#   # onPresence: (stanza) =>
#   #   console.log 'presence'
#   #   console.log stanza
#   # 
#   #   return
#   #   
#   #   stanza = $(stanza)
#   #   
#   #   jid = stanza.attr('from')
#   #   type = stanza.attr('type')
#   # 
#   #   # # Subscription request from service?
#   #   # if (jid.indexOf('@') < 0 && type === 'subscribe') {
#   # 
#   #   # Always allow
#   #   @c.send($pres({ type: 'subscribed', to: jid }));
#   # 
#   #   presence = $(stanza)
#   #   
#   #   jid = presence.attr('from').replace(/\/.+/,'')
#   #     
#   #   user = if Users.findByJid(jid)
#   #     Users.findByJid(jid)
#   #   else
#   #     user = new User {
#   #       jid : jid
#   #     }
#   #     
#   #     if presence.find('status')
#   #       user.set { status : presence.find('status').text() }
#   #     
#   #     Users.add user
#   #     
#   #     user
#   # 
#   #   user.grantChannelPermissions()
#   #            
#   #   true
#   # 
#   # grantChannelPermissions: (jid, node) ->
#   #   id = @c.getUniqueId("LM")
#   # 
#   #   stanza = $iq({"id":id, "to":PUBSUB_BRIDGE, "type":"set"})
#   #     .c("pubsub", {"xmlns":"http://jabber.org/protocol/pubsub"})
#   #     .c("affiliations", { "node" : node })
#   #     .c("affiliation", { "jid" : jid, affiliation : "follower+post" })
#   # 
#   #   @c.send(stanza.tree())
#   # 
#   # createMyChannel: ->
#   #   id = @c.getUniqueId("LM")
#   # 
#   #   stanza = $iq({"id":id, "to":PUBSUB_BRIDGE, "type":"set"})
#   #     .c("pubsub", {"xmlns":"http://jabber.org/protocol/pubsub"})
#   #     .c("create", { "node" : app.currentUser.channelId() }).up()
#   # 
#   #   @c.send(stanza.tree())
#   #   
#   #   @grantChannelPermissions app.currentUser.get('jid'), app.currentUser.channelId()
#   #   
#   # fetchRoster: ->
#   #   request = $iq({ type : 'get' })
#   #     .c('query', { xmlns: Strophe.NS.ROSTER })
#   #     
#   #   @c.sendIQ(
#   #     request
#   #     (response) =>
#   #       @_parseRoster $(response)
#   #     (err) ->
#   #       console.log 'Error recieving roster'
#   #       console.log err
#   #   )
#   #   
#   # _parseRoster: (response) ->
#   #   addItem = (item) =>
#   #     user = @roster.findOrCreateByJid item.attr('jid')
#   #     user.set { subscription : item.attr('subscription'), group : item.find('group:first').text()  }
#   #     user.save()
#   #   
#   #   for item in response.find('item')
#   #     addItem($(item))
#   #     
# 
# @LegacyConnector = LegacyConnector