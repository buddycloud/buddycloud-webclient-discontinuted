{ Connection } = require './xmpp/connection'

window.backend = new Connection()
#     .use('disco', require './xmpp/disco')


backend.on 'online', ->
    console.log "ONLINE"

#     domain = config.home_domain
#     console.log "discover channel server (#{domain}) …"
#     backend.disco.queryInfo(domain)



