{ Model } = require 'models/base'

class exports.Post extends Model

    defaults: ->
        author:
            jid: undefined
            name: undefined
            uri: undefined
        content:
            type: undefined
            value: undefined
        published: new Date().toISOString()
        updated: new Date().toISOString()

    initialize: ->
        result = super
        @author = app.users.get @get('author').jid, create:yes
        result
