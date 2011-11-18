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
        @bind 'change', =>
            if @hasChanged('unread')
                @trigger 'change:unread'
        result

    update_attributes: =>
        if (jid = @get('author')?.jid)
            @author = app.users.get_or_create id: jid

    get_last_update: =>
        @get('updated') or @get('published') or "#{new Date(0)}"

    mark_read: ->
        @unset 'unread'
