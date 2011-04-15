class Jid
  constructor: (jid) ->
    @jid = jid
    
  getDomain: ->
    @jid.replace(/.+?@/,'').replace(/\/.+/,'')
    
  getNode: ->
    @jid.replace(/@.+/,'')
  
  buddycloudDomain: ->
    (@getDomain() == "buddycloud.com")  || (@getDomain() == "diaspora-x.com")

@Jid = Jid