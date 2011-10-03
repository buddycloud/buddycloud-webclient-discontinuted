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
        @bind 'change', @update_attributes
        do @update_attributes
        result

    update_attributes: =>
        if (jid = @get('author')?.jid)
            @author = app.users.get jid, create:yes
